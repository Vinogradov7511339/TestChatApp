//
//  MessageCellDelegate.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import Foundation
import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser

extension ChatViewController: MessageCellDelegate {

    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        if let image = message.imageAttachment?.image {
            let skImage = SKPhoto.photoWithImage(image)
            let browser = SKPhotoBrowser(photos: [skImage])
            browser.initializePageIndex(0)
            present(browser, animated: true, completion: nil)
        } else if let videoURL = message.videoAttachment?.url {
            let player = AVPlayer(url: videoURL)
            let controller = AVPlayerViewController()
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            controller.player = player
            present(controller, animated: true) {
                controller.player?.play()
            }
        }
    }

    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        guard let location = message.locationAttachment?.location else { return }
        let controller = MapViewController()
        controller.location = location
        navigationController?.pushViewController(controller, animated: true)
    }
}
