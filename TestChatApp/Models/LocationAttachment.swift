//
//  LocationAttachment.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 01.11.2021.
//

import Foundation
import CoreLocation
import MessageKit

class LocationAttachment: NSObject, LocationItem {

    var location: CLLocation
    var size: CGSize

    init(_ location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240.0, height: 240.0)
    }
}
