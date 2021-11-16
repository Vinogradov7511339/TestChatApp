//
//  User.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 25.10.2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable {

    let id: String
    var username: String
    let email: String
    let pushId: String?
    var avatarLink: String?
    var status: String?

    static var currentId: String? {
        return Auth.auth().currentUser?.uid
    }

    static var currentUser: User? {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.data(forKey: kCurrentUser) else {
            return nil
        }

        let decoder = JSONDecoder()
        do {
            let user = try decoder.decode(User.self, from: data)
            return user
        } catch {
            assert(false, "decode failure: \(error.localizedDescription)")
            return nil
        }
    }

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Mock data
extension User {
    static func mockUsers() {
        let names = ["Chris_Mannix", "Joe_Gage", "Daisy_Domergue", "Oswaldo_Mobray", "Sanford_Smithers", "Señor_Bob"]
        for (index, status) in Status.allCases.enumerated() {
            if index > 5 { return }
            let id = UUID().uuidString
            let fileDirectory = "Avatars/_" + id + ".jpg"
            let image = UIImage(named: names[index])!
            FileStorage.uploadImage(image, directory: fileDirectory) { result in
                switch result {
                case .success(let link):
                    let name = names[index].replacingOccurrences(of: "_", with: " ")
                    let user = User(id: id,
                                    username: name,
                                    email: "user\(index)@gmail.com",
                                    pushId: nil,
                                    avatarLink: link,
                                    status: status.rawValue)
                    FUserListener.shared.saveUserToFirestore(user) { error in
                        if let error = error {
                            assertionFailure(error.localizedDescription)
                        }
                    }
                case .failure(let error):
                    assertionFailure(error.localizedDescription)
                    break
                }
            }

        }
    }
}
