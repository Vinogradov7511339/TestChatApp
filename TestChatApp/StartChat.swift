//
//  StartChat.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 27.10.2021.
//

import Foundation
import Firebase

// return chat room
func startChat(user1: User, user2: User, currentUser: User) -> String {
    let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2], currentUser: currentUser)
    return chatRoomId
}

func restartChat(chatRoomId: String, memberIds: [String]) {
    FUserListener.shared.downloadUsers(with: memberIds) { result in
        switch result {
        case .failure(let error):
            assert(false, error.localizedDescription)
        case .success(let users):
            createRecentItems(chatRoomId: chatRoomId, users: users, currentUser: User.currentUser!)
        }
    }
}

func createRecentItems(chatRoomId: String, users: [User], currentUser: User) {
    FirebaseReference(.recent).whereField(kChatRoomId, isEqualTo: chatRoomId).getDocuments { snapshot, error in
        guard let snapshot = snapshot else { return }

        let ids = snapshot.documents.compactMap { $0.data()[kSenderId] as? String }

        var memberIdsToCreateRecent = users.map { $0.id }
        memberIdsToCreateRecent = memberIdsToCreateRecent.filter { !ids.contains($0) }

        memberIdsToCreateRecent.forEach { userId in
            let anotherUser = users.filter { $0 != currentUser }.first!
            let sender = userId == currentUser.id ? currentUser : anotherUser
            let receiver = userId == currentUser.id ? anotherUser : currentUser

            let recentChat = RecentChat(
                id: UUID().uuidString,
                chatRoomId: chatRoomId,
                senderId: sender.id,
                senderName: sender.username,
                receiverId: receiver.id,
                receiverName: receiver.username,
                memberIds: users.map { $0.id },
                lastMessage: "",
                unreadCounter: 0,
                avatarLink: receiver.avatarLink)
            FRecentListener.shared.save(recent: recentChat)
        }
    }
}

// provides always same chat room id regardless of params positions
// return chat room id
func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    let value = user1Id.compare(user2Id).rawValue
    return value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
}
