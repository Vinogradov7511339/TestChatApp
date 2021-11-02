//
//  MKMessage.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {

    var messageId: String
    var kind: MessageKind
    var senderMK: MKSender
    var incoming: Bool
    var sentDate: Date
    var senderInitials: String
    var imageAttachment: ImageMessage?
    var videoAttachment: VideoAttachment?
    var locationAttachment: LocationAttachment?
    var audioAttachment: AudioAttachment?
    var status: String
    var readDate: Date

    var sender: SenderType {
        return senderMK
    }

    init(_ message: LocalMessage) {
        messageId = message.id
        senderMK = MKSender(senderId: message.senderId, displayName: message.senderName)
        incoming = User.currentId! != message.senderId
        sentDate = message.createdAt
        senderInitials = message.senderInitials
        status = message.status
        readDate = message.readAt

        if message.type == kTextMessageType {
            kind = .text(message.message)
        } else if message.type == kImageMessageType {
            let item = ImageMessage(path: message.imageURL)
            kind = .photo(item)
            imageAttachment = item
        } else if message.type == kVideoMessageType {
            let videoItem = VideoAttachment(url: nil)
            kind = .video(videoItem)
            videoAttachment = videoItem
        } else if message.type == kLocationMessageType {
            let location = CLLocation(latitude: message.latitude, longitude: message.longitude)
            let attachment = LocationAttachment(location)
            kind = .location(attachment)
            locationAttachment = attachment
        } else if message.type == kAudioMessageType {
            let attachment = AudioAttachment(duration: 2.0)
            kind = .audio(attachment)
            audioAttachment = attachment
        } else {
            kind = .text("Unknown type")
        }
    }
}
