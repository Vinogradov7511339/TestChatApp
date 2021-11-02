//
//  AudioAttachment.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 01.11.2021.
//

import Foundation
import MessageKit

class AudioAttachment: NSObject, AudioItem {

    var url: URL
    var duration: Float
    var size: CGSize

    init(duration: Float) {
        self.url = URL(fileURLWithPath: "")
        self.duration = duration
        self.size = CGSize(width: 160.0, height: 35.0)
    }
}
