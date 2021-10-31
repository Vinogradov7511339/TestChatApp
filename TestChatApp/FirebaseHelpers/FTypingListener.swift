//
//  FTypingListener.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 31.10.2021.
//

import Foundation
import Firebase

class FTypingListener {

    static let shared = FTypingListener()

    var typingListener: ListenerRegistration!

    private init() {}

    func createTypingObserver(for chatroomId: String, completion: @escaping (Bool) -> Void) {
        typingListener = FirebaseReference(.typing).document(chatroomId).addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { return }
            if snapshot.exists {
                let isTyping = snapshot.data()?
                    .filter { $0.key != User.currentId }
                    .first?.value as? Bool
                completion(isTyping ?? false)
            } else {
                completion(false)
                let data = [User.currentId! : false]
                FirebaseReference(.typing).document(chatroomId).setData(data)
            }
        })
    }

    func removeTypingObserver() {
        typingListener.remove()
    }

    class func saveTypingCounter(isTyping: Bool, chatroomId: String) {
        let data = [User.currentId! : isTyping]
        FirebaseReference(.typing).document(chatroomId).updateData(data)
    }
}
