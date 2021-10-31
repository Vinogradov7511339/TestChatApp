//
//  RecentCell.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 27.10.2021.
//

import UIKit

class RecentCell: UITableViewCell {

    // MARK: - Views

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeCounterLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        badgeView.layer.cornerRadius = badgeView.frame.width / 2.0
    }

    func configure(recent: RecentChat) {
        usernameLabel.text = recent.receiverName
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.minimumScaleFactor = 0.9

        messageLabel.text = recent.lastMessage
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.9
        messageLabel.numberOfLines = 2

        badgeCounterLabel.text = "\(recent.unreadCounter)"
        badgeView.isHidden = recent.unreadCounter == 0

        if let date = recent.updatedAt {
            updatedAtLabel.text = timeElapsed(date)
            updatedAtLabel.adjustsFontSizeToFitWidth = true
        }

        if let avatarLink = recent.avatarLink {
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
