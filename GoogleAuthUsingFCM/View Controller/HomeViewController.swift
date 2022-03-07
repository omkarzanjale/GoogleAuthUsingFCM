//
//  HomeViewController.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 23/02/22.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import MobileCoreServices
import UniformTypeIdentifiers

class HomeViewController: UIViewController {
    
    var userData: Any?
    private var imagePicker = UIImagePickerController()
    var viewModel = UserViewModel()

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tblView: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
        viewModel.getFile()
    }
    
    private func config() {
        title = "Home"
        self.navigationItem.hidesBackButton = true
        guard let user = userData as? User else {return}
        self.userNameLabel.text = user.displayName
    }

    @IBAction func uploadFileBtnAction(_ sender: Any) {
        docControllorConfig()
    }
    
    @IBAction func uploadImgBtnAction(_ sender: Any) {
        imagePickerControllerConfig()
    }
    
    @IBAction func signoutBtnAction(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension HomeViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true) {
            let imageURL = info[UIImagePickerController.InfoKey.imageURL] as! URL
            let imageUniqueName = String(NSDate().timeIntervalSince1970 * 1000)
            self.viewModel.uploadData(folderName: "Photos", dataName: imageUniqueName, path: imageURL)
        }
    }
    
    func imagePickerControllerConfig() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
}


extension HomeViewController: UIDocumentPickerDelegate{
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let docURL = urls.first else {return}
        let fileUniqueName = String(NSDate().timeIntervalSince1970 * 1000)
        self.viewModel.uploadData(folderName: "Documents", dataName: fileUniqueName, path: docURL)
        print("import result : \(docURL)")
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    func docControllorConfig(){
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.text", "com.apple.iwork.pages.pages", "public.data"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    
    
}
