//
//  UIImage+names.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 27.10.2021.
//

import UIKit

extension UIImage {
    static let avatar: UIImage? = UIImage(named: "avatar")
    static let imagePlaceholder = UIImage(named: "photoPlaceholder")
    static let back: UIImage? = UIImage(systemName: "chevron.left")
    static let camera: UIImage? = UIImage(systemName: "camera")
    static let photo: UIImage? = UIImage(systemName: "photo")
    static let mapPin: UIImage? = UIImage(systemName: "mappin.and.ellipse")

    static let plus = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30.0))
    static let mic = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30.0))
}
