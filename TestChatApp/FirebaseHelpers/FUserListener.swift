//
//  FUserListener.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 25.10.2021.
//

import Foundation
import Firebase

struct NotVerifiedEmailError: Error {}
struct NoUserDocumentError: Error {}
struct EmptyUserError: Error {}

class FUserListener {

    static let shared = FUserListener()

    private init() {}

    // MARK: - Login

    func loginUser(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard let result = result else {
                assert(false, "result is nil, \(error?.localizedDescription ?? "")")
                completion(error)
                return
            }
            guard result.user.isEmailVerified else {
                completion(NotVerifiedEmailError())
                return
            }
            self.loadUserFromFirestore(userId: result.user.uid) { result in
                switch result {
                case .success(let user):
                    LocalStorage.save(user: user) { error in
                        completion(error)
                    }
                case .failure(let error):
                    completion(error)
                }
            }
        }
    }

    // MARK: - Logout

    func logout(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            LocalStorage.clear()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    // MARK: - Resend verification code

    func resendVerificationCode(_ email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().currentUser?.reload(completion: { error in
            if let error = error {
                completion(error)
                return
            }
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                completion(error)
            })
        })
    }

    // MARK: - Reset password

    func resetPassword(for email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }

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
}

// MARK: - Private
private extension FUserListener {
    func saveUserToFirestore(_ user: User, completion: @escaping (Error?) -> Void) {
        do {
            try FirebaseReference(.user).document(user.id).setData(from: user)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func loadUserFromFirestore(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        FirebaseReference(.user).document(userId).getDocument { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else {
                completion(.failure(NoUserDocumentError()))
                return
            }

            let result = Result {
                try querySnapshot.data(as: User.self)
            }
            switch result {
            case .success(let user):
                if let user = user {
                    completion(.success(user))
                } else {
                    completion(.failure(EmptyUserError()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
