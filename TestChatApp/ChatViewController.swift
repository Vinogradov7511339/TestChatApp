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
    }
}
