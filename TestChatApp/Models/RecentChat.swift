//
//  RecentChat.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 27.10.2021.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentChat: Codable {
    let id: String
    let chatRoomId: String
    let senderId: String
    let senderName: String
    let receiverId: String
    let receiverName: String
    @ServerTimestamp var updatedAt = Date()
    let memberIds: [String]
    var lastMessage: String
    var unreadCounter: Int
    let avatarLink: String?
}
