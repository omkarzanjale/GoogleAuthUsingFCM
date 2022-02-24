//
//  SignUpViewController.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 24/02/22.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reEnteredPasswordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUnBtn: UIButton!
    
    var userViewModel: UserViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userViewModel = UserViewModel()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func resetComponentsToDefault() {
        self.activityIndicator.stopAnimating()
        self.view.backgroundColor = .white
        self.signUnBtn.isEnabled = true
    }

    private func validateSignInInput() ->(email: String, password: String, name: String)? {
        guard let email = emailTextField.text else {return nil }
        guard let reEnteredPassword = reEnteredPasswordTextField.text else {return nil }
        guard let password = passwordTextField.text else { return nil}
        guard let name = nameTextField.text else {return nil}
        if email.isEmpty{
            self.resetComponentsToDefault()
            self.showAlert(title: "Warning", message: "Enter Email")
        }else {
            if password.isEmpty && reEnteredPassword.isEmpty {
                self.resetComponentsToDefault()
                self.showAlert(title: "Warning", message: "Enter Password")
            } else {
                if password == reEnteredPassword {
                    if name.isEmpty {
                        self.resetComponentsToDefault()
                        self.showAlert(title: "Warning", message: "Enter Name!")
                    }else {
                        return (email,password,name)
                    }
                } else {
                    self.resetComponentsToDefault()
                    self.showAlert(title: "Warning", message: "Both Password must be same")
                }
            }
        }
        return nil
    }
    
    private func navigateToHomePage() {
        if let homeViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            homeViewControllerObj.userData = userViewModel?.user
            navigationController?.pushViewController(homeViewControllerObj, animated: true)
        }
    }
    
    @IBAction func signUpBtnAction(_ sender: Any) {
        self.activityIndicator.startAnimating()
        self.view.backgroundColor = .gray
        self.signUnBtn.isEnabled = false
        guard let data = validateSignInInput() else { return }
        userViewModel?.registerNewUser(withEmail: data.email, password: data.password, name: data.name) { [weak self] in
            DispatchQueue.main.async {
                self?.resetComponentsToDefault()
                self?.navigateToHomePage()
            }
        }
    }
}
