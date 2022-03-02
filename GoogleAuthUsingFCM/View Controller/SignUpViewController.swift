//
//  SignUpViewController.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 24/02/22.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reEnteredPasswordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUnBtn: UIButton!
    
    var userViewModel: UserViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userViewModel = UserViewModel()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func resetComponentsToDefault() {
        self.activityIndicator.stopAnimating()
        self.view.backgroundColor = .white
        self.signUnBtn.isEnabled = true
    }
    
    private func navigateToHomePage() {
        if let homeViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            homeViewControllerObj.userData = userViewModel?.user
            navigationController?.pushViewController(homeViewControllerObj, animated: true)
        }
    }
    //
    //MARK: Email/Password Authentication
    //
    @IBAction func signUpBtnAction(_ sender: Any) {
        self.activityIndicator.startAnimating()
        self.view.backgroundColor = .gray
        self.signUnBtn.isEnabled = false
        if let data = TextfieldsValidation.validateSignInInput(email: emailTextField.text, password: passwordTextField.text, confirmedPass: reEnteredPasswordTextField.text, name: nameTextField.text) {
            userViewModel?.registerNewUser(withEmail: data.email, password: data.password, name: data.name) { [weak self] in
                DispatchQueue.main.async {
                    self?.resetComponentsToDefault()
                    self?.navigateToHomePage()
                }
            } failed: { [weak self]error in
                self?.resetComponentsToDefault()
                self?.showAlert(title: "Warning", message: error)
            }
        } else {
            self.resetComponentsToDefault()
            self.showAlert(title: "Warning", message: "Enter valid data in Textfields!")
        }
    }
    
    func navigateToFirebaseDataVC(_ fromCloudData: Bool = false) {
        if let fireBaseDataViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "FireBaseDataViewController") as? FireBaseDataViewController {
            fireBaseDataViewControllerObj.dataFromCloud = fromCloudData
            self.navigationController?.pushViewController(fireBaseDataViewControllerObj, animated: true)
        }
    }
    //
    //MARK: Realtime Database
    //
    @IBAction func firebaseDBBtnAction() {
        if let data = TextfieldsValidation.validateSignInInput(email: emailTextField.text, password: passwordTextField.text, confirmedPass: reEnteredPasswordTextField.text, name: nameTextField.text) {
            self.userViewModel?.addUserToRealtimeDB(name: data.name, email: data.email, password: data.password) {[weak self] in
                self?.navigateToFirebaseDataVC()
            }
        }else {
            self.resetComponentsToDefault()
            self.navigateToFirebaseDataVC()
        }
    }
    //
    //MARK: Firestore cloud
    //
    @IBAction func firestoreCloudBtnAction(_ sender: Any) {
        if let data = TextfieldsValidation.validateSignInInput(email: emailTextField.text, password: passwordTextField.text, confirmedPass: reEnteredPasswordTextField.text, name: nameTextField.text){
            userViewModel?.uploadDataToCloud(name: data.name, email: data.email, password: data.password, complisherHandler: {[weak self] in
                self?.navigateToFirebaseDataVC(true)
            }, failed: {[weak self] in
                self?.showAlert(title: "Warining", message: "Unable to upload data to cloud!")
            })
        } else {
            self.resetComponentsToDefault()
            self.showAlert(title: "Warning", message: "Enter valid data in Textfields!")
        }
    }
}
