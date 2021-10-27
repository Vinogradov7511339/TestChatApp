//
//  ProfileViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 27.10.2021.
//

import UIKit

class ProfileViewController: UITableViewController {

    // MARK: - Views

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    // MARK: - Public variables

    var user: User?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        updateUI()
    }

    private func updateUI() {
        guard let user = user else { return }
        title = user.username
        usernameLabel.text = user.username
        statusLabel.text = user.status ?? ""
        if let avatarLink = user.avatarLink {
            loadAvatar(avatarLink)
        } else {
            avatarImageView.image = .avatar?.circleMasked
        }
    }

    private func loadAvatar(_ link: String) {
        FileStorage.downloadImage(link) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.avatarImageView.image = image.circleMasked
                case .failure(_):
                    self.avatarImageView.image = .avatar?.circleMasked
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .tableviewBG
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 5.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
