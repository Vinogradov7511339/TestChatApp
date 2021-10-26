//
//  ResetPasswordViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 25.10.2021.
//

import UIKit
import ProgressHUD

protocol ResetPasswordViewControllerDelegate: AnyObject {
    func resetPasswordLinkSended()
}

class ResetPasswordViewController: UIViewController {

    weak var delegate: ResetPasswordViewControllerDelegate?

    // MARK: - Views

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupBGTapRecognizer()
    }


    func resetPassword() {
        guard let email = emailTextField.text else {
            ProgressHUD.showFailed(Const.emptyInputError)
            return
        }
        FUserListener.shared.resetPassword(for: email) { error in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            self.delegate?.resetPasswordLinkSended()
        }
    }
}

// MARK: - Actions
extension ResetPasswordViewController {
    @IBAction func resetButtonTouchUpInside(_ sender: UIButton) {
        resetPassword()
    }

    @objc func textFieldDidChangeValue(_ textField: UITextField) {
        emailLabel.text = textField.hasText ? Const.email : Const.emptyText
    }

    @objc func bgViewTapped() {
        view.endEditing(false)
    }
}

// MARK: - Setup
private extension ResetPasswordViewController {
    func setupTextFields() {
        emailTextField.addTarget(
            self,
            action: #selector(textFieldDidChangeValue(_:)),
            for: .editingChanged)
    }

    func setupBGTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(bgViewTapped))
        view.addGestureRecognizer(tapRecognizer)
    }
}

extension ResetPasswordViewController {
    enum Const {
        static let email = NSLocalizedString("", value: "Email", comment: "")
        static let emptyText = ""
        static let emptyInputError = NSLocalizedString("", value: "All fields are required", comment: "")
    }
}
