//
//  ChannelChat+MessagesDataSource.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 03.11.2021.
//

import Foundation
import MessageKit

extension ChannelChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return currentUser
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard indexPath.section.isMultiple(of: 3) else { return nil }
        let text = MessageKitDateFormatter.shared.string(from: message.sentDate)
        let font = UIFont.boldSystemFont(ofSize: 10.0)
        let color = UIColor.darkGray
        return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard indexPath.section != messages.count - 1 else { return nil }
        let font = UIFont.boldSystemFont(ofSize: 10.0)
        let color = UIColor.darkGray
        let text = message.sentDate.time()
        return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
    }
}
