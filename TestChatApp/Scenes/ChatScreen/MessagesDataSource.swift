//
//  MessagesDataSource.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import Foundation
import MessageKit

extension ChatViewController: MessagesDataSource {
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

    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard isFromCurrentSender(message: message) else { return nil }
        let message = messages[indexPath.section]
        let status = indexPath.section == messages.count - 1 ? message.status + " " + message.readDate.time() : ""
        let font = UIFont.boldSystemFont(ofSize: 10.0)
        let color = UIColor.darkGray
        return NSAttributedString(string: status, attributes: [.font: font, .foregroundColor: color])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard indexPath.section != messages.count - 1 else { return nil }
        let font = UIFont.boldSystemFont(ofSize: 10.0)
        let color = UIColor.darkGray
        let text = message.sentDate.time()
        return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
    }
}
