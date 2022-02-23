//
//  HomeViewController.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 23/02/22.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class HomeViewController: UIViewController {
    
    var userData: Any?

    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        guard let user = userData as? User else {return}
        self.userNameLabel.text = user.displayName
    }

    @IBAction func signoutBtnAction(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
