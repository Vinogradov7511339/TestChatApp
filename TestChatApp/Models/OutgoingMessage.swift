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
        } else if let image = image {
            sendImageMessage(message, image: image, memberIds: memberIds)
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

    class func sendImageMessage(_ message: LocalMessage, image: UIImage, memberIds: [String]) {
        message.message = Const.image
        message.type = kImageMessageType
        let fileName = Date().string()
        let fileDirectory = "MediaMessages/Photo/" + message.chatRoomId + "_\(fileName)" + ".jpg"

        if let nsData = image.jpegData(compressionQuality: 0.6) {
            FileStorage.save(file: nsData as NSData, name: fileName)
        }

        FileStorage.uploadImage(image, directory: fileDirectory) { result in
            switch result {
            case .success(let imageURL):
                message.imageURL = imageURL
                send(message: message, memberIds: memberIds)
            case .failure(let error):
                assert(false, error.localizedDescription)
            }
        }
    }

    class func send(message: LocalMessage, memberIds: [String]) {
        RealmManager.shared.save(message)
        memberIds.forEach { FMessageListener.shared.add(message: message, memberId: $0) }
    }
}

extension OutgoingMessage {
    enum Const {
        static let image = NSLocalizedString("", value: "image", comment: "")
    }
}
