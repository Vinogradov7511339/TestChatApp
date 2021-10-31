//
//  OutgoingMessage.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift

class OutgoingMessage {
    class func send(chatId: String, text: String?, image: UIImage?, video: String?, audio: String?, audioDuration: Float?, location: String?, memberIds: [String]) {
        let message = defaultMessage(chatId: chatId)
        if let text = text {
            sendTextMessage(message, text: text, memberIds: memberIds)
        }
        FRecentListener.shared.updateRecent(chatroomId: chatId, lastMessage: message.message)
    }
}

// MARK: - Private
private extension OutgoingMessage {
    class func defaultMessage(chatId: String) -> LocalMessage {
        let currentUser = User.currentUser!
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.createdAt = Date()
        message.status = kSent
        return message
    }

    class func sendTextMessage(_ message: LocalMessage, text: String, memberIds: [String]) {
        message.message = text
        message.type = kTextMessageType
        send(message: message, memberIds: memberIds)
    }

    class func send(message: LocalMessage, memberIds: [String]) {
        RealmManager.shared.save(message)
        memberIds.forEach { FMessageListener.shared.add(message: message, memberId: $0) }
    }
}
