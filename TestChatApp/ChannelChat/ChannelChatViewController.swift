//
//  ChannelChatViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 03.11.2021.
//

import Foundation
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChannelChatViewController: MessagesViewController {

    // MARK: - Private variables

    private let chatId: String
    private let recipientId: String
    private let recipientName: String
    private var channel: Channel!

    private let refreshControl = UIRefreshControl()
    private let micButton = InputBarButtonItem()

    lazy var currentUser: MKSender = {
        let user = User.currentUser!
        return MKSender(senderId: user.id, displayName: user.username)
    }()
    var messages: [MKMessage] = []
    var localMessages: Results<LocalMessage>!
    let realm = try! Realm()
    var notificationToken: NotificationToken?

    var displayingMessagesCount = 0
    var maxMessagesNumber = 0
    var minMessagesNumber = 0

    var gallery: GalleryController!

    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName = ""
    var audioDuration: Date!

    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)

    // MARK: - Lifecycle

    init(channel: Channel) {
        self.channel = channel
        self.chatId = channel.id
        self.recipientId = channel.id
        self.recipientName = channel.name
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestureRecognizer()
        configureBackBarButtonItem()
        configureNavBar()
        configureCollectonView()
        configureInputBar()
        loadMessages()
        listenForNewChats()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FRecentListener.shared.resetUnreadCounter(for: chatId)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioController.stopAnyOngoingPlaying()
        FRecentListener.shared.resetUnreadCounter(for: chatId)
    }

    @objc func goBack() {
        FRecentListener.shared.resetUnreadCounter(for: chatId)
        removeListeners()
        navigationController?.popViewController(animated: true)
    }

    @objc func startRecordingAudio() {
        switch longPressGesture.state {
        case .began:
            audioDuration = Date()
            audioFileName = Date().string()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:
            AudioRecorder.shared.finishRecording()
            guard FileStorage.isFileExist(audioFileName + ".m4a") else { return }
            let duration = audioDuration.interval(of: .second, from: Date())
            messageSend(text: nil, image: nil, video: nil, audio: audioFileName, location: nil, audioDuration: duration)
            audioFileName = ""
        default:
            break
        }
    }

    func showAttachmentsDialog() {
        messageInputBar.inputTextView.resignFirstResponder()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: Const.camera, style: .default) { _ in
            self.showImageGallery(camera: true)
        }
        let media = UIAlertAction(title: Const.library, style: .default) { _ in
            self.showImageGallery(camera: false)
        }
        let location = UIAlertAction(title: Const.shareLocation, style: .default) { _ in
            guard LocationManager.shared.currentLocation != nil else { return }
            self.messageSend(text: nil, image: nil, video: nil, audio: nil, location: kLocationMessageType, audioDuration: nil)
        }
        let cancel = UIAlertAction(title: Const.cancel, style: .cancel)

        camera.setValue(UIImage.camera, forKey: "image")
        media.setValue(UIImage.photo, forKey: "image")
        location.setValue(UIImage.mapPin, forKey: "image")
        alert.addAction(camera)
        alert.addAction(media)
        alert.addAction(location)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    func configureBackBarButtonItem() {
        let button = UIBarButtonItem(image: .back, style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItems = [button]
    }

    func configureNavBar() {
        navigationItem.largeTitleDisplayMode = .never
        title = channel.name
    }

    func configureCollectonView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshControl
    }

    func configureInputBar() {
        messageInputBar.isHidden = channel.adminId != User.currentId!
        let addAttachmentButton = InputBarButtonItem()
        addAttachmentButton.image = .plus
        let attchmentButtonSize = CGSize(width: 30.0, height: 30.0)
        addAttachmentButton.setSize(attchmentButtonSize, animated: false)
        addAttachmentButton.onTouchUpInside { _ in
            self.showAttachmentsDialog()
        }

        micButton.image = .mic
        let micButtonSize = CGSize(width: 30.0, height: 30.0)
        micButton.setSize(micButtonSize, animated: false)
        micButton.addGestureRecognizer(longPressGesture)

        messageInputBar.delegate = self
        messageInputBar.setStackViewItems([addAttachmentButton], forStack: .left, animated: false)
        updateMickButtonState(false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36.0, animated: false)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }

    func configureGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(startRecordingAudio))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delaysTouchesBegan = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            if displayingMessagesCount < localMessages.count {
                loadOldMessages(maxNumber: maxMessagesNumber, minNumber: minMessagesNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshControl.endRefreshing()
        }
    }

    func updateMickButtonState(_ isHidden: Bool) {
        if isHidden {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 60.0, animated: false)
        } else {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30.0, animated: false)
        }
    }

    func messageSend(text: String?,
                     image: UIImage?,
                     video: Video?,
                     audio: String?,
                     location: String?,
                     audioDuration: Float?) {
        OutgoingMessage.send(chatId: chatId,
                             text: text,
                             image: image,
                             video: video,
                             audio: audio,
                             audioDuration: audioDuration,
                             location: location,
                             memberIds: [User.currentId!, recipientId])
    }

    func loadMessages() {
        let predicate = NSPredicate(format: "\(kChatRoomId) = %@", chatId)
        localMessages = realm
            .objects(LocalMessage.self)
            .filter(predicate)
            .sorted(byKeyPath: kCreatedDate, ascending: true)

        if localMessages.isEmpty {
            checkForOldChats()
        }

        notificationToken = localMessages.observe({ (changes: RealmCollectionChange) in
            switch changes {
            case .initial(_):
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
            case .update(_, _, let insertions, _):
                insertions.forEach { self.insert(message: self.localMessages[$0]) }
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
            case .error(let error):
                assert(false, error.localizedDescription)
            }
        })
    }

    func listenForNewChats() {
        let date = lastMessageDate()
        FMessageListener.shared.listenForNewChats(User.currentId!, collectionId: chatId, lastMessageDate: date)
    }

    func lastMessageDate() -> Date {
        let lastDate = localMessages.last?.createdAt ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastDate) ?? lastMessageDate()
    }

    func checkForOldChats() {
        FMessageListener.shared.checkForOldChats(User.currentId!, collectionId: chatId)
    }

    func insertMessages() {
        maxMessagesNumber = localMessages.count - displayingMessagesCount
        minMessagesNumber = maxMessagesNumber - kNumberOfMessages
        minMessagesNumber = max(0, minMessagesNumber)
        (minMessagesNumber..<maxMessagesNumber)
            .forEach { insert(message: localMessages[$0]) }
    }

    func insert(message: LocalMessage) {
        displayingMessagesCount += 1
        let incoming = IncomingMessage(self)
        if let mkMessage = incoming.createMessage(from: message) {
            messages.append(mkMessage)
        }
    }

    // MARK: - rename to "load next batch"
    func loadOldMessages(maxNumber: Int, minNumber: Int) {
        maxMessagesNumber = minNumber
        minMessagesNumber = maxMessagesNumber - kNumberOfMessages
        minMessagesNumber = max(0, minMessagesNumber)
        (minMessagesNumber..<maxMessagesNumber).reversed()
            .forEach { insertOlder(message: localMessages[$0]) }
    }

    func insertOlder(message: LocalMessage) {
        displayingMessagesCount += 1
        let incoming = IncomingMessage(self)
        if let mkMessage = incoming.createMessage(from: message) {
            messages.insert(mkMessage, at: 0)
        }
    }

    func removeListeners() {
        FMessageListener.shared.removeObservers()
    }
}

extension ChannelChatViewController {
    func showImageGallery(camera: Bool) {
        gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30.0
        present(gallery, animated: true, completion: nil)
    }
}

// MARK: - GalleryControllerDelegate
extension ChannelChatViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        guard let image = images.first else { return }
        image.resolve { uiImage in
            if let uiImage = uiImage {
                self.messageSend(text: nil, image: uiImage, video: nil, audio: nil, location: nil, audioDuration: nil)
            } else {
                assert(false, "corrupted image")
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        messageSend(text: nil, image: nil, video: video, audio: nil, location: nil, audioDuration: nil)
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ChannelChatViewController {
    enum Const {
        static let typing = NSLocalizedString("", value: "Typing ...", comment: "")
        static let emptyText = NSLocalizedString("", value: "", comment: "")
        static let camera = NSLocalizedString("", value: "Camera", comment: "")
        static let library = NSLocalizedString("", value: "Library", comment: "")
        static let shareLocation = NSLocalizedString("", value: "Share Location", comment: "")
        static let cancel = NSLocalizedString("", value: "Cancel", comment: "")
    }
}
