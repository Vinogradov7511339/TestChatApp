//
//  ChannelCell.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 02.11.2021.
//

import UIKit

class ChannelCell: UITableViewCell {

    // MARK: - Views

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!

    // MARK: - Lifecycle

    func configure(with  channel: Channel) {
        titleLabel.text = channel.name
        descriptionLabel.text = channel.about
        membersLabel.text = "\(channel.memberIds.count) " + Const.members
        lastUpdateLabel.text = timeElapsed(channel.updatedAt ?? Date())
        lastUpdateLabel.adjustsFontSizeToFitWidth = true
        if let avatarLink = channel.avatarLink {
            loadAvatar(avatarLink)
        }
    }

    private func loadAvatar(_ link: String) {
        FileStorage.downloadImage(link) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.avatarImageView.image = image.circleMasked
                case .failure(_):
                    self.avatarImageView.image = .avatar
                }
            }
        }
    }

}

extension ChannelCell {
    enum Const {
        static let members = NSLocalizedString("", value: "members", comment: "")
    }
}
