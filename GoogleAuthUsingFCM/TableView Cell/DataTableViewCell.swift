//
//  DataTableViewCell.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 25/02/22.
//

import UIKit

class DataTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
   
    func updateData(user: UserModel) {
        if user.name.isEmpty {
            nameLabel.isHidden = true
        }else {
            nameLabel.isHidden = false
            self.nameLabel.text = "Name : " + user.name
        }
        if user.email.isEmpty {
            emailLabel.isHidden = true
        } else {
            emailLabel.isHidden = false
            self.emailLabel.text = "Email : " + user.email
        }
        if user.name.isEmpty {
            passwordLabel.isHidden = true
        }else {
            passwordLabel.isHidden = false
            self.passwordLabel.text = "Password : " + String(repeating: "*", count: user.password.count)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
