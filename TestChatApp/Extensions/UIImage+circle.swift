//
//  UIImage+circle.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 26.10.2021.
//

import UIKit

extension UIImage {

    var isPortrait: Bool { size.height > size.width }
    var isLandscape: Bool { size.height < size.width }
    var breadth: CGFloat { min(size.height, size.width) }
    var breadthSize: CGSize { CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect { CGRect(origin: .zero, size: breadthSize) }

    var circleMasked: UIImage? {
        defer { UIGraphicsEndImageContext() }
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)

        let origin = CGPoint(
            x: isLandscape ? floor((size.width - size.height) / 2) : 0.0,
            y: isPortrait ? floor((size.height - size.width) / 2) : 0.0
        )
        let rect = CGRect(origin: origin, size: breadthSize)
        guard let cgImage = cgImage?.cropping(to: rect) else {
            return nil
        }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
