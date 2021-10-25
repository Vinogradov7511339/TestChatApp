//
//  ViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 24.10.2021.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {

    enum ScreenState {
        case signIn
        case signUp
    }

    // MARK: - Views

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!

    @IBOutlet weak var repeatPasswordSeparator: UIView!

    // MARK: - Private variables

    private var currentState: ScreenState = .signIn

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupBGTapRecognizer()
        updateUI(for: currentState)
    }

    func isDataInputed(for state: ScreenState) -> Bool {
        switch state {
        case .signIn:
            return emailTextField.hasText && passwordTextField.hasText
        case .signUp:
            return emailTextField.hasText
            && passwordTextField.hasText
            && repeatPasswordTextField.hasText
        }
    }
}

// MARK: - Actions
extension LoginViewController {
    @IBAction func loginButtonTouchUpInside(_ sender: UIButton) {
        if isDataInputed(for: currentState) {

        } else {
            ProgressHUD.showFailed(Const.emptyInputError)
        }
    }

    @IBAction func forgotButtonTouchUpInside(_ sender: UIButton) {

    }

    @IBAction func resendButtonTouchUpInside(_ sender: UIButton) {

    }

    @IBAction func signUpButtonTouchUpInside(_ sender: UIButton) {
        switch currentState {
        case .signIn:
            currentState = .signUp
        case .signUp:
            currentState = .signIn
        }
        updateUI(for: currentState)
    }

    @objc func textFieldDidChangeValue(_ textField: UITextField) {
        updatePlaceholders(for: textField)
    }

    @objc func bgViewTapped() {
        view.endEditing(false)
    }
}

// MARK: - Setup
private extension LoginViewController {
    func setupTextFields() {
        emailTextField.addTarget(
            self,
            action: #selector(textFieldDidChangeValue(_:)),
            for: .editingChanged)
        passwordTextField.addTarget(
            self,
            action: #selector(textFieldDidChangeValue(_:)),
            for: .editingChanged)
        repeatPasswordTextField.addTarget(
            self,
            action: #selector(textFieldDidChangeValue(_:)),
            for: .editingChanged)
    }

    func setupBGTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(bgViewTapped))
        view.addGestureRecognizer(tapRecognizer)
    }
}

// MARK: - Screen states & UI updates
private extension LoginViewController {
    func updatePlaceholders(for textField: UITextField) {
        switch textField {
        case emailTextField:
            emailLabel.text = textField.hasText ? Const.email : Const.emptyText
        case passwordTextField:
            passwordLabel.text = textField.hasText ? Const.password : Const.emptyText
        case repeatPasswordTextField:
            repeatPasswordLabel.text = textField.hasText ? Const.repeatPassword : Const.emptyText
        default:
            assert(false, "unexpected state")
        }
    }

    func updateUI(for state: ScreenState) {
        switch state {
        case .signIn: prepareSignInState()
        case .signUp: prepareSignUpState()
        }
    }

    func prepareSignInState() {
        let image = UIImage.Login.loginButton
        loginButton.setImage(image, for: .normal)

        signUpButton.setTitle(Const.signUp, for: .normal)

        signUpLabel.text = Const.signUpQuestion

        UIView.animate(withDuration: 0.2) {
            self.repeatPasswordLabel.isHidden = true
            self.repeatPasswordTextField.isHidden = true
            self.repeatPasswordSeparator.isHidden = true
        }
    }

    func prepareSignUpState() {
        let image = UIImage.Login.registerButton
        loginButton.setImage(image, for: .normal)

        signUpButton.setTitle(Const.signIn, for: .normal)

        signUpLabel.text = Const.signInQuestion

        UIView.animate(withDuration: 0.5) {
            self.repeatPasswordLabel.isHidden = false
            self.repeatPasswordTextField.isHidden = false
            self.repeatPasswordSeparator.isHidden = false
        }
    }
}

extension LoginViewController {
    enum Const {
        static let email = NSLocalizedString("", value: "Email", comment: "")
        static let password = NSLocalizedString("", value: "Password", comment: "")
        static let repeatPassword = NSLocalizedString("", value: "Repeat Password", comment: "")
        static let emptyText = ""

        static let signUp = NSLocalizedString("", value: "Sign up", comment: "")
        static let signIn = NSLocalizedString("", value: "Sign in", comment: "")

        static let signUpQuestion = NSLocalizedString("", value: "Don't have an account?", comment: "")
        static let signInQuestion = NSLocalizedString("", value: "Have an account?", comment: "")

        static let emptyInputError = NSLocalizedString("", value: "All fields are required", comment: "")
    }
}


extension UIImage {
    enum Login {
        static let loginButton = UIImage(named: "loginBtn")
        static let registerButton = UIImage(named: "registerBtn")
    }
}
