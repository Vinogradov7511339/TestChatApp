//
//  FRecentListener.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 27.10.2021.
//

import Foundation
import Firebase

class FRecentListener {

    static let shared = FRecentListener()

    private init() {}

    func save(recent: RecentChat) {
        do {
            try FirebaseReference(.recent).document(recent.id).setData(from: recent)
        } catch {
            assert(false, error.localizedDescription)
        }
    }

    func downloadChats(completion: @escaping (Result<[RecentChat], Error>) -> Void) {
        FirebaseReference(.recent)
            .whereField(kSenderId, isEqualTo: User.currentId ?? "")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let recents = snapshot?.documents
                    .compactMap { try? $0.data(as: RecentChat.self) }
                    .filter { !$0.lastMessage.isEmpty }
                    .sorted { $0.updatedAt! > $1.updatedAt! } ?? []
                completion(.success(recents))
        }
    }

    func resetUnreadCounter(for chatRoomId: String) {
        FirebaseReference(.recent)
            .whereField(kChatRoomId, isEqualTo: chatRoomId)
            .whereField(kSenderId, isEqualTo: User.currentId!).getDocuments { snapshot, error in
                snapshot?.documents
                    .compactMap { try? $0.data(as: RecentChat.self) }
                    .forEach { self.nulifyUnreadCounter($0) }
            }
    }

    func nulifyUnreadCounter(_ chat: RecentChat) {
        var updatedRecent = chat
        updatedRecent.unreadCounter = 0
        save(recent: updatedRecent)
    }

    func delete(recent: RecentChat) {
        FirebaseReference(.recent).document(recent.id).delete()
    }

    func updateRecent(chatroomId: String, lastMessage: String) {
        FirebaseReference(.recent).whereField(kChatRoomId, isEqualTo: chatroomId).getDocuments { snapshot, error in
            if let error = error {
                assert(false, error.localizedDescription)
            }
            snapshot?.documents
                .compactMap { try? $0.data(as: RecentChat.self) }
                .forEach { self.update(recent: $0, with: lastMessage) }
        }
    }

    private func update(recent: RecentChat, with message: String) {
        var updatedRecent = recent
        if updatedRecent.senderId != User.currentId! {
            updatedRecent.unreadCounter += 1
        }
        updatedRecent.lastMessage = message
        updatedRecent.updatedAt = Date()
        save(recent: updatedRecent)
    }
}
