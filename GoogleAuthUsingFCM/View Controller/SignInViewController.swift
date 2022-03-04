//
//  SignInViewController.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 23/02/22.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInBtn: UIButton!
    
    var userViewModel: UserViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        self.userViewModel = UserViewModel()
        userViewModel?.restorePreviouslyLogin(complisherHandler: {[weak self] in
            self?.navigateToHomePage()
        })
    }
    
    @IBAction func crashlyticsTestBtnAction(_ sender: Any) {
        let numbers = [0]
        let _ = numbers[1]
    }
    
    private func resetComponentsToDefault() {
        self.signInBtn.isEnabled = true
        self.activityIndicator.stopAnimating()
        self.view.backgroundColor = .white
    }
    
    private func validateSignInInput() ->(email: String, password: String)? {
        guard let email = emailTextField.text else {return nil }
        guard let password = passwordTextField.text else { return nil}
        if email.isEmpty{
            self.resetComponentsToDefault()
            self.showAlert(title: "Warning", message: "Enter Email")
        }else {
            if password.isEmpty {
                self.resetComponentsToDefault()
                self.showAlert(title: "Warning", message: "Enter Password")
            } else {
                return (email,password)
            }
        }
        return nil
    }
    
    @IBAction func signInBtnAction(_ sender: Any) {
        self.activityIndicator.startAnimating()
        self.view.backgroundColor = .gray
        self.signInBtn.isEnabled = false
        guard let data = validateSignInInput() else {return}
        userViewModel?.loginUser(withEmail: data.email, password: data.password, failed: { [weak self] in
            DispatchQueue.main.async {
                self?.resetComponentsToDefault()
                self?.showAlert(title: "Warning", message: "Inalid Credentials! Try again.")
            }
        }) {[weak self] in
            DispatchQueue.main.async {
                self?.resetComponentsToDefault()
                self?.navigateToHomePage()
            }
        }
    }
    
    @IBAction func signUpBtnAction(_ sender: Any) {
        if let signUpViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            navigationController?.pushViewController(signUpViewControllerObj, animated: true)
        }
    }
    
    
    private func navigateToHomePage() {
        if let homeViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            homeViewControllerObj.userData = userViewModel?.user
            navigationController?.pushViewController(homeViewControllerObj, animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func googleSignInBtnAction(_ sender: Any) {
        self.userViewModel?.googleSignIn(controller: self, complesherHandler: {[weak self] in
            self?.navigateToHomePage()
        })
    }
    
    @IBAction func firebaseDBBtnAction() {
        self.signUpBtnAction(UIButton())
    }
}
