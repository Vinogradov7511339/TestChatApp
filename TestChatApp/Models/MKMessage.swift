//
//  MKMessage.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {

    var messageId: String
    var kind: MessageKind
    var senderMK: MKSender
    var incoming: Bool
    var sentDate: Date
    var senderInitials: String
    var status: String
    var readDate: Date

    var sender: SenderType {
        return senderMK
    }

    init(_ message: LocalMessage) {
        messageId = message.id
        kind = .text(message.message)
        senderMK = MKSender(senderId: message.senderId, displayName: message.senderName)
        incoming = User.currentId! != message.senderId
        sentDate = message.createdAt
        senderInitials = message.senderInitials
        status = message.status
        readDate = message.readAt
    }
}