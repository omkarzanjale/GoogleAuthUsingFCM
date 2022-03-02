//
//  AdditinalInfoViewController.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 02/03/22.
//

import UIKit

class AdditinalInfoViewController: UIViewController {
    @IBOutlet weak var residentialDetailsTf: UITextField!
    @IBOutlet weak var areaStreetTf: UITextField!
    @IBOutlet weak var statePostalCodeTf: UITextField!
    
    var userViewModel: UserViewModel?
    var user: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    private func config() {
        title = "Additional Info"
        self.userViewModel = UserViewModel()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func prepareData()->[String:String]? {
        guard let residentialDetails = residentialDetailsTf.text else {return nil}
        guard let areaStreetDetails = areaStreetTf.text else {return nil}
        guard let statePostalCodeDetails = statePostalCodeTf.text else {return nil}
        return ["Residential Details": residentialDetails,"Area/Street Details":areaStreetDetails, "State/PostalCode Details":statePostalCodeDetails]
    }
   
    @IBAction func uploadBtnAction(_ sender: Any) {
        guard let data = prepareData() else {return}
        userViewModel?.setAdditionalInfo(forUser: user, infoLabel: "Address", data: data, complisherHandler: {[weak self] in
            DispatchQueue.main.async {
                self?.showAlert(title: "Succeed", message: "Data uploded successfully.")
            }
        }, failed: {[weak self] in
            DispatchQueue.main.async {
                self?.showAlert(title: "Failed", message: "failed to uploded data!")
            }
        })
    }
}
