//
//  ChannelChat+MessagesLayoutDelegate.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 03.11.2021.
//

import Foundation
import MessageKit

extension ChannelChatViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.section.isMultiple(of: 3) ? 16.0 : 0.0
    }

//    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        guard isFromCurrentSender(message: message) else { return 0.0 }
//        return 16.0
//    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10.0
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let message = messages[indexPath.section]
        let avatar = Avatar(initials: message.senderInitials)
        avatarView.set(avatar: avatar)
    }
}
