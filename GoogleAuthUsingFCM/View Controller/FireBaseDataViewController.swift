//
//  FireBaseDataViewController.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 25/02/22.
//

import UIKit

class FireBaseDataViewController: UIViewController {

    @IBOutlet weak var dataList: UITableView!
    var userViewModel: UserViewModel?
    var dataFromCloud: Bool = false
    
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
                self?.dataList.reloadData()
            }
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
