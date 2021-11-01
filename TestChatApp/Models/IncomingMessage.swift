//
//  IncomingMessage.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 30.10.2021.
//

import Foundation
import MessageKit
import CoreLocation

class IncomingMessage {

    var messageViewController: MessagesViewController

    init(_ viewController: MessagesViewController) {
        self.messageViewController = viewController
    }

    func createMessage(from localMessage: LocalMessage) -> MKMessage? {
        let mkMessage = MKMessage(localMessage)
        if localMessage.type == kImageMessageType {
            let imageMessage = ImageMessage(path: localMessage.imageURL)
            mkMessage.imageAttachment = imageMessage
            mkMessage.kind = .photo(imageMessage)
            FileStorage.downloadImage(localMessage.imageURL) { result in
                switch result {
                case .success(let image):
                    mkMessage.imageAttachment?.image = image
                    DispatchQueue.main.async {
                        self.messageViewController.messagesCollectionView.reloadData()
                    }
                case .failure(let error):
                    assert(false, error.localizedDescription)
                }
            }
        } else if localMessage.type == kVideoMessageType {
            FileStorage.downloadImage(localMessage.imageURL) { result in
                switch result {
                case .success(let thumbnail):
                    FileStorage.downloadVideo(localMessage.videoURL) { result in
                        switch result {
                        case .success(let isReadyToPlay, let fileName):
                            let path = FileStorage.filePath(for: fileName)
                            let videoURL = URL(fileURLWithPath: path)
                            let videoItem = VideoAttachment(url: videoURL)
                            mkMessage.videoAttachment = videoItem
                            mkMessage.kind = .video(videoItem)
                            mkMessage.videoAttachment?.image = thumbnail
                            DispatchQueue.main.async {
                                self.messageViewController.messagesCollectionView.reloadData()
                            }
                        case .failure(let error):
                            assert(false, error.localizedDescription)
                        }
                    }
                case .failure(let error):
                    assert(false, error.localizedDescription)
                }
            }
        } else if localMessage.type == kLocationMessageType {
            let location = CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude)
            let locationItem = LocationAttachment(location)
            mkMessage.kind = .location(locationItem)
            mkMessage.locationAttachment = locationItem
        }
        return mkMessage
    }
}
