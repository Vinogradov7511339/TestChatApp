//
//  GlobalFunctions.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 26.10.2021.
//

import Foundation

func fileName(from path: String) -> String? {
    path.components(separatedBy: "_").last?
        .components(separatedBy: "?").first?
        .components(separatedBy: ".").first
}
