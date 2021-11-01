//
//  VideoAttachment.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 01.11.2021.
//

import Foundation
import MessageKit

// MARK: - rename to ImageAttachment
class VideoAttachment: NSObject, MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(url: URL?) {
        self.url = url
        placeholderImage = .imagePlaceholder!
        size = CGSize(width: 240.0, height: 240.0)
    }
}
