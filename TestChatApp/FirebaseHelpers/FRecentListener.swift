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

    func add(recent: RecentChat) {
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
}
