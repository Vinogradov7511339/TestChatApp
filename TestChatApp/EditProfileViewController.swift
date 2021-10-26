//
//  EditProfileViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 26.10.2021.
//

import UIKit
import ProgressHUD
import Gallery

class EditProfileViewController: UITableViewController {

    // MARK: - Views

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!

    // MARK: - Private variables

    var gallery: GalleryController?
    

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        configureTextField()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUserInfo()
    }

    func updateUserInfo() {
        guard let user = User.currentUser else { return }
        usernameTextField.text = user.username
        statusLabel.text = user.status ?? ""
        // TODO: - add avatar
    }

    func configureTextField() {
        usernameTextField.delegate = self
        usernameTextField.clearButtonMode = .whileEditing
    }

    func showImageGallery() {
        gallery = GalleryController()
        gallery?.delegate = self
        Config.tabsToShow = [.cameraTab, .imageTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab

        present(gallery!, animated: true, completion: nil)
    }
}

// MARK: - Actions
extension EditProfileViewController {
    @IBAction func editButtonTouchUpInside(_ sender: UIButton) {
        showImageGallery()
    }
}

// MARK: - GalleryControllerDelegate
extension EditProfileViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
        guard let image = images.first else { return }
        image.resolve { uiImage in
            guard let uiImage = uiImage else {
                ProgressHUD.showError(Const.corruptedImage)
                return
            }
            self.avatarImageView.image = uiImage
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

// MARK: - UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField === usernameTextField else { return true }
        guard let text = textField.text else { return true }
        guard var user = User.currentUser else { return true }
        user.username = text
        LocalStorage.save(user: user) { error in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            FUserListener.shared.saveUserToFirestore(user) { error in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }
                ProgressHUD.showSuccess(Const.changeNameSuccess)
                textField.endEditing(true)
            }
        }
        return true
    }
}

extension EditProfileViewController {
    enum Const {
        static let changeNameSuccess = NSLocalizedString("", value: "You name changed", comment: "")
        static let corruptedImage = NSLocalizedString("", value: "Corrupted image", comment: "")
    }
}
