//
//  LocalStorage.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 25.10.2021.
//

import Foundation

class LocalStorage {

    static let shared = LocalStorage()

    private init() {}

    // TODO: - add error handler
    static func save(user: User, completion: @escaping (Error?) -> Void) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(user)
            UserDefaults.standard.set(data, forKey: kCurrentUser)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
