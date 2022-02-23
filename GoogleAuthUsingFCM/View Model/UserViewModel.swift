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
   // var userUpdate: (()->())? = nil
    
    init(controller: UIViewController) {
        googleSignIn(controller: controller)
    }
    
    private func googleSignIn(controller: UIViewController) {
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
                }
            }
        }
    }
    
}
