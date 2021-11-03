//
//  ChannelChat+MessageCellDelegate.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 03.11.2021.
//

import Foundation
import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser

extension ChannelChatViewController: MessageCellDelegate {

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

    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                assert(false, "no cell for index cell")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}

