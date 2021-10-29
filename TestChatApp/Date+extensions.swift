//
//  Date+extensions.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 27.10.2021.
//

import Foundation

extension Date {
    func longDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
