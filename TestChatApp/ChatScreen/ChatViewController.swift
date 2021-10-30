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
        configureCollectonView()
        configureInputBar()
        loadMessages()
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
        addAttachmentButton.onTouchUpInside { _ in }

        micButton.image = .mic
        let micButtonSize = CGSize(width: 30.0, height: 30.0)
        micButton.setSize(micButtonSize, animated: false)
        // TODO: - gesture recognizer

        messageInputBar.delegate = self
        messageInputBar.setStackViewItems([addAttachmentButton], forStack: .left, animated: false)
//        messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36.0, animated: false)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
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

    func insertMessages() {
        localMessages.forEach { insert(message: $0) }
    }

    func insert(message: LocalMessage) {
        let incoming = IncomingMessage(self)
        if let mkMessage = incoming.createMessage(from: message) {
            messages.append(mkMessage)
        }
    }
}
