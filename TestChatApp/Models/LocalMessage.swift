//
//  LocalMessage.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import Foundation
import RealmSwift

class LocalMessage: Object, Codable {

    @objc dynamic var id = ""
    @objc dynamic var chatRoomId = ""
    @objc dynamic var createdAt = Date()
    @objc dynamic var senderId = ""
    @objc dynamic var senderName = ""
    @objc dynamic var senderInitials = ""
    @objc dynamic var readAt = Date()
    @objc dynamic var type = ""
    @objc dynamic var status = ""
    @objc dynamic var message = ""
    @objc dynamic var audioURL = ""
    @objc dynamic var audioDuration: Double = 0.0
    @objc dynamic var videoURL = ""
    @objc dynamic var imageURL = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0

    override class func primaryKey() -> String? {
        return "id"
    }
}
