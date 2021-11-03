//
//  ChannelDetailsViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 02.11.2021.
//

import UIKit
import ProgressHUD

class ChannelDetailsViewController: UITableViewController {

    // MARK: - Views

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!

    // MARK: - Public variables

    var channel: Channel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        configureNavBar()
        setupViews()
    }
}

// MARK: - Actions
extension ChannelDetailsViewController {
    @objc func followTouchUpInside() {
        follow()
    }
}

// MARK: - Private
private extension ChannelDetailsViewController {
    func configureNavBar() {
        navigationItem.largeTitleDisplayMode = .never
        title = channel!.name
        let button = UIBarButtonItem(
            title: Const.follow,
            style: .plain,
            target: self,
            action: #selector(followTouchUpInside)
        )
        navigationItem.rightBarButtonItem = button
    }

    func setupViews() {
        nameLabel.text = channel.name
        membersLabel.text = "\(channel.memberIds.count) " + Const.members
        aboutTextView.text = channel.about
        guard let link = channel.avatarLink else { return }
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

    func follow() {
        channel.memberIds.append(User.currentId!)
        FChannelListener.shared.upload(channel: channel) { error in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension ChannelDetailsViewController {
    enum Const {
        static let members = NSLocalizedString("", value: "Members", comment: "")
        static let follow = NSLocalizedString("", value: "Follow", comment: "")
    }
}
