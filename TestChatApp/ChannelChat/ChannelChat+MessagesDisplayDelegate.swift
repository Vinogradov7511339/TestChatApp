//
//  ChannelChat+MessagesDisplayDelegate.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 03.11.2021.
//

import Foundation
import MessageKit

extension ChannelChatViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .label
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? MKDefaults.bubbleColorOutgoing : MKDefaults.bubbleColorIncoming
    }


    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}
