//
//  Channel.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 02.11.2021.
//

import Foundation
import FirebaseFirestoreSwift

struct Channel: Codable {
    let id: String
    var name: String
    let adminId: String
    var memberIds: [String] = []
    var avatarLink: String?
    var about: String = ""
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
}
