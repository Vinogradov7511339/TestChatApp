//
//  ChatViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChatViewController: MessagesViewController {

    // MARK: - Views

    let leftBarButtonView: UIView = {
        let rect = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 50.0)
        let view = UIView(frame: rect)
        return view
    }()

    let titleLabel: UILabel = {
        let rect = CGRect(x: 5.0, y: 0.0, width: 180.0, height: 25.0)
        let label = UILabel(frame: rect)
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16.0, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let subtitleLabel: UILabel = {
        let rect = CGRect(x: 5.0, y: 25.0, width: 180.0, height: 20.0)
        let label = UILabel(frame: rect)
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13.0, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    // MARK: - Private variables

    private let chatId: String
    private let recipientId: String
    private let recipientName: String

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

    var typingCounter = 0

    var gallery: GalleryController!

    // MARK: - Lifecycle

    init(recent: RecentChat) {
        chatId = recent.chatRoomId
        recipientId = recent.receiverId
        recipientName = recent.receiverName
        super.init(nibName: nil, bundle: nil)
    }

    init(chatId: String, recipientId: String, recipientName: String) {
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackBarButtonItem()
        configureNavBar()
        configureCollectonView()
        configureInputBar()
        loadMessages()
        listenForNewChats()
        createTypingObserver()
        listenForReadMessageStatusChange()
    }

    @objc func goBack() {
        FRecentListener.shared.resetUnreadCounter(for: chatId)
        removeListeners()
        navigationController?.popViewController(animated: true)
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
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subtitleLabel)
        let view = UIBarButtonItem(customView: leftBarButtonView)
        navigationItem.leftBarButtonItems?.append(view)

        titleLabel.text = recipientName
        navigationItem.largeTitleDisplayMode = .never
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
        // TODO: - gesture recognizer

        messageInputBar.delegate = self
        messageInputBar.setStackViewItems([addAttachmentButton], forStack: .left, animated: false)
        updateMickButtonState(false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36.0, animated: false)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }

    func updateSubtitleState(_ show: Bool) {
        subtitleLabel.text = show ? Const.typing : Const.emptyText
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
                     video: String?,
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

    func listenForReadMessageStatusChange() {
        FMessageListener.shared.listenForReadStatusChange(User.currentId!, collectionId: chatId) { updatedMessage in
            guard updatedMessage.status != kSent else { return }
            self.update(message: updatedMessage)
        }
    }

    func update(message: LocalMessage) {
        messages
            .filter { $0.messageId == message.id }
            .forEach {
                $0.status = message.status
                $0.readDate = message.readAt
                RealmManager.shared.save(message)
                if $0.status == kRead {
                    messagesCollectionView.reloadData()
                }
            }
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
        if message.senderId != User.currentId {
            markMessageAsRead(message)
        }
        displayingMessagesCount += 1
        let incoming = IncomingMessage(self)
        if let mkMessage = incoming.createMessage(from: message) {
            messages.append(mkMessage)
        }
    }

    func markMessageAsRead(_ message: LocalMessage) {
        guard message.senderId != User.currentId! else { return }
        guard message.status != kRead else { return }
        FMessageListener.shared.update(message: message, memberIds: [User.currentId!, recipientId])
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
        FTypingListener.shared.removeTypingObserver()
        FMessageListener.shared.removeObservers()
    }
}

// MARK: - Typing indicator
extension ChatViewController {
    func typingIndicatorUpdate() {
        typingCounter += 1
        FTypingListener.saveTypingCounter(isTyping: true, chatroomId: chatId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.typingCounterStop()
        }
    }

    func typingCounterStop() {
        typingCounter -= 1
        if typingCounter == 0 {
            FTypingListener.saveTypingCounter(isTyping: false, chatroomId: chatId)
        }
    }

    func createTypingObserver() {
        FTypingListener.shared.createTypingObserver(for: chatId) { isTyping in
            DispatchQueue.main.async {
                self.updateSubtitleState(isTyping)
            }
        }
    }

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
extension ChatViewController: GalleryControllerDelegate {
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
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ChatViewController {
    enum Const {
        static let typing = NSLocalizedString("", value: "Typing ...", comment: "")
        static let emptyText = NSLocalizedString("", value: "", comment: "")
        static let camera = NSLocalizedString("", value: "Camera", comment: "")
        static let library = NSLocalizedString("", value: "Library", comment: "")
        static let shareLocation = NSLocalizedString("", value: "Share Location", comment: "")
        static let cancel = NSLocalizedString("", value: "Cancel", comment: "")
    }
}
