//
//  User.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 25.10.2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable {

    let id: String
    var username: String
    let email: String
    let pushId: String?
    var avatarLink: String?
    var status: String?

    static var currentId: String? {
        return Auth.auth().currentUser?.uid
    }

    static var currentUser: User? {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.data(forKey: kCurrentUser) else {
            return nil
        }

        let decoder = JSONDecoder()
        do {
            let user = try decoder.decode(User.self, from: data)
            return user
        } catch {
            assert(false, "decode failure: \(error.localizedDescription)")
            return nil
        }
    }

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
