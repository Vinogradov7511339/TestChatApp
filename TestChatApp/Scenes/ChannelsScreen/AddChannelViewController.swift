//
//  AddChannelViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 02.11.2021.
//

import UIKit
import Gallery
import ProgressHUD

class AddChannelViewController: UITableViewController {

    // MARK: - Views

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var infoTextView: UITextView!

    // MARK: - Public variables

    var channelToEdit: Channel?

    // MARK: - Private variables

    private var gallery: GalleryController!
    private var tapGesture = UITapGestureRecognizer()
    private var avatarLink: String?
    private var channelId = UUID().uuidString

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        configureNavBar()
        configureGesture()
        fillChannelInfoIfNeeded()
    }
}

// MARK: - Actions
extension AddChannelViewController {
    @IBAction func saveTouchUpInside(_ sender: UIBarButtonItem) {
        if channelToEdit != nil {
            updateChannel()
        } else {
            saveChannel()
        }
    }

    @objc func avatarImageTap() {
        showGallery()
    }

    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Private
private extension AddChannelViewController {
    func configureGesture() {
        tapGesture.addTarget(self, action: #selector(avatarImageTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }

    func configureNavBar() {
        if channelToEdit != nil {
            title = Const.editingModeTitle
        }
        navigationItem.largeTitleDisplayMode = .never
        let button = UIBarButtonItem(image: .back, style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = button
    }

    func fillChannelInfoIfNeeded() {
        guard let channel = channelToEdit else { return }
        channelId = channel.id
        nameTextField.text = channel.name
        infoTextView.text = channel.about
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

    func showGallery() {
        gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        present(gallery, animated: true, completion: nil)
    }

    func upload(image: UIImage) {
        let directory = "Avatars/_" + channelId + ".jpg"
        FileStorage.uploadImage(image, directory: directory) { result in
            switch result {
            case .success(let link):
                self.avatarLink = link
                FileStorage.save(file: image.jpegData(compressionQuality: 0.7)! as NSData, name: self.channelId)
            case .failure(let error):
                ProgressHUD.showError(error.localizedDescription)
            }
        }
    }

    func saveChannel() {
        guard let channelName = nameTextField.text else {
            ProgressHUD.showError(Const.emptyNameError)
            return
        }
        let channel = Channel(
            id: channelId,
            name: channelName,
            adminId: User.currentId!,
            memberIds: [User.currentId!],
            avatarLink: avatarLink,
            about: infoTextView.text ?? "",
            createdAt: Date(),
            updatedAt: Date()
        )
        FChannelListener.shared.upload(channel: channel) { error in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    func updateChannel() {
        guard var channel = channelToEdit else { return }
        guard let channelName = nameTextField.text else {
            ProgressHUD.showError(Const.emptyNameError)
            return
        }
        channel.name = channelName
        channel.about = infoTextView.text ?? ""
        channel.updatedAt = Date()
        FChannelListener.shared.upload(channel: channel) { error in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - GalleryControllerDelegate
extension AddChannelViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        defer { controller.dismiss(animated: true, completion: nil) }
        guard let image = images.first else { return }
        image.resolve { uiImage in
            if let uiImage = uiImage {
                self.avatarImageView.image = uiImage.circleMasked
                self.upload(image: uiImage)
            } else {
                ProgressHUD.showError(Const.corruptedImageError)
            }
        }

    }

    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }


}

extension AddChannelViewController {
    enum Const {
        static let corruptedImageError = NSLocalizedString("", value: "Corrupted image, try choose another", comment: "")
        static let emptyNameError = NSLocalizedString("", value: "Channel name is required", comment: "")
        static let editingModeTitle = NSLocalizedString("", value: "Editing Channel", comment: "")
    }
}
