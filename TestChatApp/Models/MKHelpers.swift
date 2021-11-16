//
//  MKHelpers.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import Foundation
import UIKit
import MessageKit

struct MKSender: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

enum MKDefaults {
    static let bubbleColorOutgoing = UIColor.chatOutgoingBubble!
    static let bubbleColorIncoming = UIColor.chatIncomingBubble!
}
