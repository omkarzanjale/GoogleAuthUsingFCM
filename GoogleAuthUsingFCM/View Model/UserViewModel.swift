//
//  UserViewModel.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 23/02/22.
//

import Foundation
import FirebaseCore
import GoogleSignIn
import FirebaseAuth

class UserViewModel {
    
    private(set) var user: User?
    
    func restorePreviouslyLogin(complisherHandler:()->()) {
        if Auth.auth().currentUser != nil {
            self.user = Auth.auth().currentUser
            complisherHandler()
        } 
    }
    
    
    //MARK: Google
    func googleSignIn(controller: UIViewController,complesherHandler:@escaping ()->()) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: controller ) { [unowned self] user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    self?.user = authResult?.user
                    complesherHandler()
                }
            }
        }
    }
    
    //MARK: Email/Password
    
    func registerNewUser(withEmail email: String, password: String, name: String, complesherHandler:@escaping ()->()) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] auth, error in
            if error == nil {
                let changeRequest = auth?.user.createProfileChangeRequest()
                changeRequest?.displayName = name
                changeRequest?.commitChanges { [weak self] error in
                    print("Account Created")
                    self?.user = auth?.user
                    complesherHandler()
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    func loginUser(withEmail email: String, password: String, complesherHandler:@escaping ()->()) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] auth, error in
            if error == nil {
                print("successful Login")
                self?.user = auth?.user
                complesherHandler()
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
}
