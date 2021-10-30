//
//  RealmManager.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import Foundation
import RealmSwift

class RealmManager {

    static let shared = RealmManager()

    private let realm = try! Realm()

    private init() {}

    func save<T: Object>(_ object: T) {
        do {
            try realm.write({
                realm.add(object, update: .all)
            })
        } catch {
            assert(false, error.localizedDescription)
        }
    }
}
