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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    private func config() {
        self.userViewModel = UserViewModel()
        title = "All Users"
        self.userViewModel?.getUsersFromRealtimeDB{ [weak self] in
            DispatchQueue.main.async {
                self?.dataList.reloadData()
            }
        }
    }
}

extension FireBaseDataViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userViewModel?.UsersFromDB.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = dataList.dequeueReusableCell(withIdentifier: "DataTableViewCell", for: indexPath) as? DataTableViewCell {
            guard let user = userViewModel?.UsersFromDB[indexPath.row] else{return UITableViewCell()}
            cell.updateData(user: user)
            return cell
        }else {
            return UITableViewCell()
        }
        
    }
}
