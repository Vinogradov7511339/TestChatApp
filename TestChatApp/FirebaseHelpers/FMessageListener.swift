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
    var newChatListener: ListenerRegistration!
    var updatedChatListener: ListenerRegistration!

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

    func add(to channel: Channel, message: LocalMessage) {
        do {
            let _ = try FirebaseReference(.messages)
                .document(channel.id)
                .collection(channel.id)
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

    // TODO: - change local params names
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        newChatListener = FirebaseReference(.messages).document(documentId).collection(collectionId).whereField(kCreatedDate, isGreaterThan: lastMessageDate).addSnapshotListener({ snapshot, error in
            if let error = error {
                assert(false, error.localizedDescription)
                return
            }
            snapshot?.documentChanges
                .filter { $0.type == .added }
                .compactMap { try? $0.document.data(as: LocalMessage.self) }
                .filter { $0.senderId != User.currentId! }
                .forEach { RealmManager.shared.save($0) }
        })
    }

    func update(message: LocalMessage, memberIds: [String]) {
        let fieldsToUpdate: [String: Any] = [kMessageStatus: kRead, kReadDate: Date()]
        memberIds.forEach { FirebaseReference(.messages).document($0).collection(message.chatRoomId).document(message.id).updateData(fieldsToUpdate)}
    }

    func listenForReadStatusChange(_ documentId: String, collectionId: String, completion: @escaping (LocalMessage) -> Void) {
        updatedChatListener = FirebaseReference(.messages).document(documentId).collection(collectionId).addSnapshotListener({ snapshot, error in
            if let error = error {
                assert(false, error.localizedDescription)
                return
            }
            snapshot?.documentChanges
                .filter { $0.type == .modified }
                .compactMap { try? $0.document.data(as: LocalMessage.self) }
                .forEach { completion($0) }

        })
    }

    func removeObservers() {
        newChatListener?.remove()
        updatedChatListener?.remove()
    }
}
