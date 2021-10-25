//
//  FUserListener.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 25.10.2021.
//

import Foundation
import Firebase

class FUserListener {

    static let shared = FUserListener()

    private init() {}

    // MARK: - Login

    // MARK: - Register

    func registerUser(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard let result = result else {
                assert(false, "result is nil, \(error?.localizedDescription ?? "")")
                completion(error)
                return
            }

            // create user
            let user = User(id: result.user.uid,
                            username: email,
                            email: email,
                            pushId: nil,
                            avatarLink: nil,
                            status: nil)

            // save user localy
            LocalStorage.save(user: user) { error in
                guard error == nil else {
                    completion(error)
                    return
                }
                // save user to firestore
                self.saveUserToFirestore(user) { error in
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    // send verification email
                    result.user.sendEmailVerification(completion: completion)
                }
            }
        }
    }

    func saveUserToFirestore(_ user: User, completion: @escaping (Error?) -> Void) {
        do {
            try FirebaseReference(.user).document(user.id).setData(from: user)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
