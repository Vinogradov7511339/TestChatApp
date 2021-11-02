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

    func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }

    func string() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyyHHmmss"
        return dateFormatter.string(from: self)
    }

    func interval(of component: Calendar.Component, from date: Date) -> Float {
        let calendar = Calendar.current
        guard let start = calendar.ordinality(of: component, in: .era, for: date) else { return 0.0 }
        guard let end = calendar.ordinality(of: component, in: .era, for: self) else { return 0.0 }
        return Float(start - end)
    }
}
