//
//  SceneDelegate.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 24.10.2021.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        autoLogin()
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}

    func logout() {
        let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "loginController")
        window?.rootViewController = controller
    }


    // MARK: - Autologin

    func autoLogin() {
        authListener = Auth.auth().addStateDidChangeListener({ auth, user in
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            if user != nil && LocalStorage.isUserExist {
                DispatchQueue.main.async {
                    self.goToApp()
                }
            }
        })
    }

    private func goToApp() {
        let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "MainApp")
        window?.rootViewController = controller
    }
}

