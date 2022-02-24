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
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let name = nameTextField.text else {return}
        userViewModel?.registerNewUser(withEmail: email, password: password, name: name) { [weak self] in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.view.backgroundColor = .white
                self?.signUnBtn.isEnabled = true
                self?.navigateToHomePage()
            }
        }
    }
}
