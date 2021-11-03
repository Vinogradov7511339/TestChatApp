//
//  OutgoingMessage.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift
import Gallery

class OutgoingMessage {
    class func send(chatId: String, text: String?, image: UIImage?, video: Video?, audio: String?, audioDuration: Float?, location: String?, memberIds: [String]) {
        let message = defaultMessage(chatId: chatId)
        if let text = text {
            sendTextMessage(message, text: text, memberIds: memberIds)
        } else if let image = image {
            sendImageMessage(message, image: image, memberIds: memberIds)
        } else if let video = video {
            sendVideoMessage(message, video: video, memberIds: memberIds)
        } else if location != nil {
            sendLocationMessage(message, memberIds: memberIds)
        } else if let audio = audio, let duration = audioDuration {
            sendAudioMessage(message, audio: audio, duration: duration, memberIds: memberIds)
        }
        FRecentListener.shared.updateRecent(chatroomId: chatId, lastMessage: message.message)
    }

    class func send(to channel: Channel, text: String?, image: UIImage?, video: Video?, audio: String?, audioDuration: Float?, location: String?, memberIds: [String]) {
        var channel = channel
        let message = defaultMessage(chatId: channel.id)
        if let text = text {
            sendTextMessage(message, text: text, memberIds: memberIds, channel: channel)
        } else if let image = image {
            sendImageMessage(message, image: image, memberIds: memberIds, channel: channel)
        } else if let video = video {
            sendVideoMessage(message, video: video, memberIds: memberIds, channel: channel)
        } else if location != nil {
            sendLocationMessage(message, memberIds: memberIds, channel: channel)
        } else if let audio = audio, let duration = audioDuration {
            sendAudioMessage(message, audio: audio, duration: duration, memberIds: memberIds, channel: channel)
        }
        channel.updatedAt = Date()
        FChannelListener.shared.upload(channel: channel) { error in
            if let error = error {
                assert(false, error.localizedDescription)
            }
        }
    }
}

// MARK: - Private
private extension OutgoingMessage {
    class func defaultMessage(chatId: String) -> LocalMessage {
        let currentUser = User.currentUser!
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.createdAt = Date()
        message.status = kSent
        return message
    }

    class func sendTextMessage(_ message: LocalMessage, text: String, memberIds: [String], channel: Channel? = nil) {
        message.message = text
        message.type = kTextMessageType
        if let channel = channel {
            send(to: channel, message: message)
        } else {
            send(message: message, memberIds: memberIds)
        }
    }

    class func sendImageMessage(_ message: LocalMessage, image: UIImage, memberIds: [String], channel: Channel? = nil) {
        message.message = Const.image
        message.type = kImageMessageType
        let fileName = Date().string()
        let fileDirectory = "MediaMessages/Photo/" + message.chatRoomId + "_\(fileName)" + ".jpg"

        if let nsData = image.jpegData(compressionQuality: 0.6) {
            FileStorage.save(file: nsData as NSData, name: fileName)
        }

        FileStorage.uploadImage(image, directory: fileDirectory) { result in
            switch result {
            case .success(let imageURL):
                message.imageURL = imageURL
                if let channel = channel {
                    send(to: channel, message: message)
                } else {
                    send(message: message, memberIds: memberIds)
                }
            case .failure(let error):
                assert(false, error.localizedDescription)
            }
        }
    }

    class func sendVideoMessage(_ message: LocalMessage, video: Video, memberIds: [String], channel: Channel? = nil) {
        message.message = Const.video
        message.type = kVideoMessageType
        let fileName = Date().string()
        let thumbnailDirectory = "MediaMessages/Photo/" + message.chatRoomId + "_\(fileName)" + ".jpg"
        let fileDirectory = "MediaMessages/Video/" + message.chatRoomId + "_\(fileName)" + ".mov"
        let editor = VideoEditor()
        editor.process(video: video) { video, tempPath in
            guard let tempPath = tempPath else {
                assert(false, "No path for video")
                return
            }
            let thumbnail = videoThumbnail(pathToVideo: tempPath)
            FileStorage.save(file: thumbnail.jpegData(compressionQuality: 0.7)! as NSData, name: fileName)
            FileStorage.uploadImage(thumbnail, directory: thumbnailDirectory) { result in
                switch result {
                case .success(let thumbnailLink):
                    let videoData = NSData(contentsOfFile: tempPath.path)
                    FileStorage.save(file: videoData!, name: fileName + ".mov")
                    FileStorage.uploadVideo(videoData!, directory: fileDirectory) { result in
                        switch result {
                        case .success(let videoPath):
                            message.imageURL = thumbnailLink
                            message.videoURL = videoPath
                            if let channel = channel {
                                send(to: channel, message: message)
                            } else {
                                send(message: message, memberIds: memberIds)
                            }
                        case .failure(let error):
                            assert(false, error.localizedDescription)
                        }
                    }
                case .failure(let error):
                    assert(false, error.localizedDescription)
                }
            }
        }
    }

    class func sendLocationMessage(_ message: LocalMessage, memberIds: [String], channel: Channel? = nil) {
        let location = LocationManager.shared.currentLocation
        message.message = Const.location
        message.type = kLocationMessageType
        message.latitude = location?.latitude ?? 0.0
        message.longitude = location?.longitude ?? 0.0
        if let channel = channel {
            send(to: channel, message: message)
        } else {
            send(message: message, memberIds: memberIds)
        }
    }

    class func sendAudioMessage(_ message: LocalMessage, audio: String, duration: Float, memberIds: [String], channel: Channel? = nil) {
        message.message = Const.audio
        message.type = kAudioMessageType
        let filePath = "MediaMessages/Audio/" + message.chatRoomId + "_\(audio)" + ".m4a"
        FileStorage.uploadAudio(audioFileName: audio, directory: filePath) { result in
            switch result {
            case .success(let pathToFile):
                message.audioURL = pathToFile
                message.audioDuration = Double(duration)
                if let channel = channel {
                    send(to: channel, message: message)
                } else {
                    send(message: message, memberIds: memberIds)
                }
            case .failure(let error):
                assert(false, error.localizedDescription)
            }
        }
    }

    class func send(message: LocalMessage, memberIds: [String]) {
        RealmManager.shared.save(message)
        memberIds.forEach { FMessageListener.shared.add(message: message, memberId: $0) }
    }

    class func send(to channel: Channel, message: LocalMessage) {
        RealmManager.shared.save(message)
        FMessageListener.shared.add(to: channel, message: message)
    }
}

extension OutgoingMessage {
    enum Const {
        static let image = NSLocalizedString("", value: "image", comment: "")
        static let video = NSLocalizedString("", value: "video", comment: "")
        static let location = NSLocalizedString("", value: "location", comment: "")
        static let audio = NSLocalizedString("", value: "audio", comment: "")
    }
}
