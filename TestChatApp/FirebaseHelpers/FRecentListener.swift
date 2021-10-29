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
}
