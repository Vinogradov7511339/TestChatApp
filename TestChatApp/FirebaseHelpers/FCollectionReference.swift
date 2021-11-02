//
//  FCollectionReference.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 25.10.2021.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case user = "User"
    case recent = "Recent"
    case messages = "Messages"
    case typing = "Typing"
    case channel = "Channel"
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
