//
//  FireBaseDataViewController.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 25/02/22.
//

import UIKit

class FireBaseDataViewController: UIViewController {

    @IBOutlet weak var dataList: UITableView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    var userViewModel: UserViewModel?
    var dataFromCloud: Bool = false //is/does
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        if dataFromCloud {
            firestoreConfig()
        }else {
            realtimeDBConfig()
        }
    }
    
    private func config() {
        self.userViewModel = UserViewModel()
        dataList.tableFooterView = UIView()
        dataList.separatorStyle = .none
    }
    
    private func realtimeDBConfig() {
        title = "Realtime DB Users"
        self.userViewModel?.getUsersFromRealtimeDB{ [weak self] in
            DispatchQueue.main.async {
                self?.dataList.reloadData()
            }
        }
    }
    
    private func firestoreConfig() {
        title = "Cloud Users"
        self.userViewModel?.getDataFromCloud {[weak self] in
            DispatchQueue.main.async {
                self?.dataList.reloadData()//tbldata
            }
        }
    }
    
    @IBAction func uploadBtnAction(_ sender: Any) {
        if let data = TextfieldsValidation.validateSignInInput(email: emailTF.text, password: passwordTF.text, confirmedPass: passwordTF.text, name: nameTF.text) {
            self.userViewModel?.addUserToRealtimeDB(name: data.name, email: data.email, password: data.password) {}
        }
    }
}

extension FireBaseDataViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataFromCloud {
            return userViewModel?.usersfromCloud.count ?? 0
        } else {
            return userViewModel?.UsersFromDB.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = dataList.dequeueReusableCell(withIdentifier: "DataTableViewCell", for: indexPath) as? DataTableViewCell {
            if dataFromCloud {
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
        if dataFromCloud {
            guard let user = userViewModel?.usersfromCloud[indexPath.row] else{return}
            navigateToDetails(user: user.email)
        }
    }
}
