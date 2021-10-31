//
//  FMessageListener.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FMessageListener {

    static let shared = FMessageListener()

    private init() {}

    func add(message: LocalMessage, memberId: String) {
        do {
            let _ = try FirebaseReference(.messages)
                .document(memberId)
                .collection(message.chatRoomId)
                .document(message.id)
                .setData(from: message)
        } catch {
            assert(false, error.localizedDescription)
        }
    }

    // TODO: - change local params names
    func checkForOldChats(_ documentId: String, collectionId: String) {
        FirebaseReference(.messages).document(documentId).collection(collectionId).getDocuments { snapshot, error in
            if let error = error {
                assert(false, error.localizedDescription)
                return
            }
            snapshot?.documents
                .compactMap { try? $0.data(as: LocalMessage.self) }
                .sorted { $0.createdAt < $1.createdAt }
                .forEach { RealmManager.shared.save($0) }
        }
    }
}
