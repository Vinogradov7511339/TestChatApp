//
//  SettingsViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 26.10.2021.
//

import UIKit
import ProgressHUD

class SettingsViewController: UITableViewController {

    // MARK: - Views

    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderTopPadding = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUserInfo()
    }

    func updateUserInfo() {
        let version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0"
        appVersionLabel.text = Const.appVersionText + version
        guard let user = User.currentUser else { return }
        usernameLabel.text = user.username
        statusLabel.text = user.status
        guard let avatarURL = user.avatarLink else { return }
        FileStorage.downloadImage(avatarURL) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.avatarImageView.image = image
                case .failure(let error):
                    ProgressHUD.showError(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Actions
extension SettingsViewController {
    @IBAction func shareButtonTouchUpInside(_ sender: UIButton) {}

    @IBAction func policyButtonTouchUpInside(_ sender: UIButton) {}

    @IBAction func logoutButtonTouchUpInside(_ sender: UIButton) {
        FUserListener.shared.logout { error in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                (self.view.window?.windowScene?.delegate as? SceneDelegate)?.logout()
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .tableviewBG
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 10.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController {
    enum Const {
        static let appVersionText = NSLocalizedString("", value: "App version: ", comment: "")
    }
}
