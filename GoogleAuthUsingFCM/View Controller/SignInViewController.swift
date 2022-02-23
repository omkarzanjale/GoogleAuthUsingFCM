//
//  SignInViewController.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 23/02/22.
//

import UIKit
import FirebaseAuth


class SignInViewController: UIViewController {

    var userViewModel: UserViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        isUserPreviouslyLogined()
    }
    
    private func isUserPreviouslyLogined() {
        let firebaseAuth = Auth.auth()
        firebaseAuth.addStateDidChangeListener { [weak self]auth, user in
            if user != nil {
                self?.navigateToHomePage(user: user)
            }
        }
    }
    
    private func navigateToHomePage(user: User? = nil) {
        if let homeViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            homeViewControllerObj.userData = userViewModel?.user ?? user
            navigationController?.pushViewController(homeViewControllerObj, animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func googleSignInBtnAction(_ sender: Any) {
        self.userViewModel = UserViewModel(controller: self)
    }
    
}
