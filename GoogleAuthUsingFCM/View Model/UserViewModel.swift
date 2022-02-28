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
import FirebaseDatabase

class UserViewModel {
    
    private(set) var user: User?
    private(set) var UsersFromDB = [UserModel]()
    private let ref = Database.database().reference()
    typealias failureClosure = ()->()
    
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
    
    func loginUser(withEmail email: String, password: String, failed:@escaping failureClosure ,complesherHandler:@escaping ()->()) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] auth, error in
            if error == nil {
                print("successful Login")
                self?.user = auth?.user
                complesherHandler()
            } else {
                print(error!.localizedDescription)
                failed()
            }
        }
    }
    
    
    //MARK: Realtime database
    
    func addUserToRealtimeDB(name: String, email: String, password: String, complisherHandler: @escaping()->()) {
        ref.child("Users").childByAutoId().setValue(["Name":name,"Email":email,"Password":password]) { error, reference in
            if let err = error {
                print(err.localizedDescription)
                
            } else {
                print("successfully added")
                complisherHandler()
            }
        }
    }
    
    func getUsersFromRealtimeDB(complisherHandle:@escaping()->()) {
        self.ref.child("Users").queryOrderedByKey().observe(.childAdded) { [weak self] snapShot in
            guard let name = (snapShot.value as? NSDictionary)?["Name"] as? String else{return}
            guard let email = (snapShot.value as? NSDictionary)?["Email"] as? String else{return}
            guard let password = (snapShot.value as? NSDictionary)?["Password"] as? String else{return}
            let user = UserModel(name: name, email: email, password: password)
            self?.UsersFromDB.append(user)
            complisherHandle()
        }
    }
    
}
