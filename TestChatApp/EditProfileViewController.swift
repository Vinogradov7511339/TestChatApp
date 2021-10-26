//
//  EditProfileViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 26.10.2021.
//

import UIKit

class EditProfileViewController: UITableViewController {

    // MARK: - Views
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        updateUserInfo()
    }

    func updateUserInfo() {
        guard let user = User.currentUser else { return }
        usernameTextField.text = user.username
        statusLabel.text = user.status ?? ""
        // TODO: - add avatar
    }
}

// MARK: - Actions
extension EditProfileViewController {
    @IBAction func editButtonTouchUpInside(_ sender: UIButton) {
    }
}

// MARK: - UITableViewDelegate
extension EditProfileViewController {
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
