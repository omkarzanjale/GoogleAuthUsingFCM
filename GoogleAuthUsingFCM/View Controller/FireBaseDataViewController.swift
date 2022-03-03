//
//  FireBaseDataViewController.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 25/02/22.
//

import UIKit

class FireBaseDataViewController: UIViewController {

    @IBOutlet weak var tblDataList: UITableView!
    @IBOutlet weak var txtfName: UITextField!
    @IBOutlet weak var txtfEmail: UITextField!
    @IBOutlet weak var txtfPassword: UITextField!
    var userViewModel: UserViewModel?
    var isDataFromCloud: Bool = false //is/does
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        if isDataFromCloud {
            firestoreConfig()
        }else {
            realtimeDBConfig()
        }
    }
    
    private func config() {
        self.userViewModel = UserViewModel()
        tblDataList.tableFooterView = UIView()
        tblDataList.separatorStyle = .none
    }
    
    private func realtimeDBConfig() {
        title = "Realtime DB Users"
        self.userViewModel?.getUsersFromRealtimeDB {
            DispatchQueue.main.async {[weak self] in
                self?.tblDataList.reloadData()//tbldata
            }
        }
    }
    
    private func firestoreConfig() {
        title = "Cloud Users"
        self.userViewModel?.observeCloudData {[weak self] in
            DispatchQueue.main.async {
                self?.tblDataList.reloadData()//tbldata
            }
        }
    }
    
    @IBAction func uploadBtnAction(_ sender: Any) {
        if isDataFromCloud {
            if let data = TextfieldsValidation.validateSignInInput(email: txtfEmail.text, password: txtfPassword.text, confirmedPass: txtfPassword.text, name: txtfName.text) {
                self.userViewModel?.uploadDataToCloud(name: data.name, email: data.email, password: data.password, complisherHandler: {
                    print("Data uploaded successfully.")
                }, failed: {
                    print("Failed to upload data!")
                })
                
            }
        } else {
            if let data = TextfieldsValidation.validateSignInInput(email: txtfEmail.text, password: txtfPassword.text, confirmedPass: txtfPassword.text, name: txtfName.text) {
                self.userViewModel?.addUserToRealtimeDB(name: data.name, email: data.email, password: data.password) {[weak self] in
                    self?.userViewModel?.getLastUpdatedUser {
                        DispatchQueue.main.async {
                            self?.tblDataList.reloadData()
                        }
                    }
                }
            }
        }
    }
}

extension FireBaseDataViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDataFromCloud {
            return userViewModel?.usersfromCloud.count ?? 0
        } else {
            return userViewModel?.UsersFromDB.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tblDataList.dequeueReusableCell(withIdentifier: "DataTableViewCell", for: indexPath) as? DataTableViewCell {
            if isDataFromCloud {
                guard let user = userViewModel?.usersfromCloud[indexPath.row] else{return UITableViewCell()}
                cell.updateData(user: user)
            }else {
                guard let user = userViewModel?.UsersFromDB[indexPath.row] else{return UITableViewCell()}
                cell.updateData(user: user)
            }
            return cell
        }else {
            return UITableViewCell()
        }
        
    }
}

extension FireBaseDataViewController: UITableViewDelegate {
    
    private func navigateToDetails(user: String) {
        if let additinalViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "AdditinalInfoViewController") as? AdditinalInfoViewController {
            additinalViewControllerObj.user = user
            navigationController?.pushViewController(additinalViewControllerObj, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isDataFromCloud {
            guard let user = userViewModel?.usersfromCloud[indexPath.row] else{return}
            navigateToDetails(user: user.email)
        }
    }
}
