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
import FirebaseFirestore

class UserViewModel {
    
    private(set) var user: User?
    private(set) var UsersFromDB = [UserModel]()
    private(set) var usersfromCloud = [UserModel]()
    
    private let ref = Database.database().reference()
    
    private let firestoreDatabase = Firestore.firestore()
    var counter = Int()
    
    typealias failureClosure = ()->()
    typealias successClosure = ()->()
    
    func restorePreviouslyLogin(complisherHandler:()->()) {
        if Auth.auth().currentUser != nil {
            self.user = Auth.auth().currentUser
            complisherHandler()
        }
    }
    //
    //MARK: Google
    //
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
    //
    //MARK: Email/Password Authentication
    //
    func registerNewUser(withEmail email: String, password: String, name: String, complesherHandler:@escaping ()->(),failed: @escaping(String)->()) {
        
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
                failed(error!.localizedDescription)
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
    //
    //MARK: Realtime Database
    //
    func addUserToRealtimeDB(name: String, email: String, password: String, complisherHandler: @escaping successClosure) {
        self.ref.child("Users").childByAutoId().setValue(["Name":name,"Email":email,"Password":password]) { error, reference in
            if let err = error {
                print(err.localizedDescription)
            } else {
                print("successfully added")
                complisherHandler()
            }
        }
    }
    
    func observeUsersFromRealtimeDB(complisherHandle:@escaping successClosure) {
        UsersFromDB.removeAll()
        self.ref.child("Users").observe(.childAdded) { [weak self] snapShot in
            guard let name = (snapShot.value as? NSDictionary)?["Name"] as? String else{return}
            guard let email = (snapShot.value as? NSDictionary)?["Email"] as? String else{return}
            guard let password = (snapShot.value as? NSDictionary)?["Password"] as? String else{return}
            let user = UserModel(name: name, email: email, password: password)
            self?.UsersFromDB.append(user)
            complisherHandle()
        }
    }
    
    func getLastUpdatedUser(complisherHandle:@escaping successClosure) {
        self.ref.child("Users").queryLimited(toLast: 1).observeSingleEvent(of: .childAdded) { [weak self] snapShot in
            guard let name = (snapShot.value as? NSDictionary)?["Name"] as? String else{return}
            guard let email = (snapShot.value as? NSDictionary)?["Email"] as? String else{return}
            guard let password = (snapShot.value as? NSDictionary)?["Password"] as? String else{return}
            let user = UserModel(name: name, email: email, password: password)
            self?.UsersFromDB.append(user)
            complisherHandle()
        }
    }
    
    func getUsersFromRealtimeDB(complisherHandle:@escaping successClosure) {
        self.ref.child("Users").observeSingleEvent(of: .value) { [weak self] snapShot in
            self?.UsersFromDB.removeAll()
            guard let users = snapShot.children.allObjects as? [DataSnapshot] else {return}
            for user in users {
                guard let name = (user.value as? NSDictionary)?["Name"] as? String else{return}
                guard let email = (user.value as? NSDictionary)?["Email"] as? String else{return}
                guard let password = (user.value as? NSDictionary)?["Password"] as? String else{return}
                let user = UserModel(name: name, email: email, password: password)
                self?.UsersFromDB.append(user)
            }
            complisherHandle()
        }
    }
    //
    //MARK: Firestore Cloud
    //
    func uploadDataToCloud(name: String, email: String, password: String, complisherHandler: @escaping successClosure, failed:@escaping failureClosure) {
        setCount{
            self.counter = self.counter + 1
            let docRef = self.firestoreDatabase.collection("Users").document("\(self.counter)")
            docRef.setData(["UserId":self.counter,"Name":name,"Email":email,"Password":password]) { error in
                if error == nil {
                    complisherHandler()
                }else {
                    print(error!.localizedDescription)
                    failed()
                }
            }
        }
    }
    
    func getDataFromCloud(complisherHandler:@escaping successClosure) {
        let docRef = firestoreDatabase.collection("Users")
        docRef.getDocuments {[weak self] snapshot, error in
            self?.usersfromCloud.removeAll()
            if error == nil {
                guard let data = snapshot else {return}
                for document in data.documents {
                    let userData = document.data()
                    guard let name = userData["Name"] as? String else{return}
                    guard let email = userData["Email"] as? String else{return}
                    guard let password = userData["Password"] as? String else{return}
                    let user = UserModel(name: name, email: email, password: password)
                    self?.usersfromCloud.append(user)
                }
                self?.counter = self?.usersfromCloud.count ?? 0
                complisherHandler()
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    func getLastEntryFromCloud(complisherHandler:@escaping successClosure) {
        let docRef = firestoreDatabase.collection("Users")
        docRef.order(by: "UserId").limit(toLast: 1).getDocuments {[weak self] snapshot, error in
            if error == nil {
                guard let data = snapshot else {return}
                for document in data.documents {
                    let userData = document.data()
                    guard let name = userData["Name"] as? String else{return}
                    guard let email = userData["Email"] as? String else{return}
                    guard let password = userData["Password"] as? String else{return}
                    let user = UserModel(name: name, email: email, password: password)
                    self?.usersfromCloud.append(user)
                }
                complisherHandler()
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    func observeCloudData(complisherHandler:@escaping successClosure) {
        let docRef = firestoreDatabase.collection("Users")
        docRef.addSnapshotListener { [weak self] snapShot, error in
            guard let _ = snapShot else {return}
            snapShot?.documentChanges.forEach{ data in
                if data.type == .added {
                    let userData = data.document.data()
                    guard let name = userData["Name"] as? String else{return}
                    guard let email = userData["Email"] as? String else{return}
                    guard let password = userData["Password"] as? String else{return}
                    let user = UserModel(name: name, email: email, password: password)
                    self?.usersfromCloud.append(user)
                }
            }
            complisherHandler()
        }
    }
    
    func setCount(complisherHandler:@escaping successClosure){
        let docRef = firestoreDatabase.collection("Users")
        docRef.order(by: "UserId").getDocuments {[weak self] snapshot, error in
            if error == nil {
                self?.counter = snapshot?.documents.count ?? 0
                complisherHandler()
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    func setAdditionalInfo(forUser: String, infoLabel: String, data: [String:String],complisherHandler: @escaping successClosure, failed:@escaping failureClosure) {
        self.setCount {[weak self] in
            guard let docRef = self?.firestoreDatabase.collection("Users").document("\(self?.counter ?? 0)") else {return}
            let d = docRef.collection("Additional Info").document(infoLabel)
            d.setData(data) { error in
                if error == nil {
                    complisherHandler()
                }else {
                    print(error!.localizedDescription)
                    failed()
                }
            }
        }
    }
}
