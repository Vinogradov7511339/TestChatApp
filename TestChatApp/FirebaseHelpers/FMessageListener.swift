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
}
