//
//  UserCell.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 27.10.2021.
//

import UIKit

class UserCell: UITableViewCell {

    // MARK: - Views

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with user: User) {
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
}
