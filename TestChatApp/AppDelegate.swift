//
//  AppDelegate.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 24.10.2021.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var wasLaunched: Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    // MARK: - First launch

    private func firstLaunchCheck() {
        wasLaunched = UserDefaults.standard.bool(forKey: kFirstLaunch)
        guard !wasLaunched else { return }
        UserDefaults.standard.set(true, forKey: kFirstLaunch)

        let statuses = Status.allCases.map { $0.rawValue }
        UserDefaults.standard.set(statuses, forKey: kUserStatus)
    }
}

