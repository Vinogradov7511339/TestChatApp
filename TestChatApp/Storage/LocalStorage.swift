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

    static var isUserExist: Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: kCurrentUser) != nil
    }

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

    static func clear() {
        UserDefaults.standard.removeObject(forKey: kCurrentUser)
    }
}
