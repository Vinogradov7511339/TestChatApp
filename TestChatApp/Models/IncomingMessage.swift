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
        return mkMessage
    }
}
