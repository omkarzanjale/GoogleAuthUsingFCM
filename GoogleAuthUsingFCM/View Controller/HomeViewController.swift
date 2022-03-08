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
import Toast_Swift

class HomeViewController: UIViewController {
    
    var userData: Any?
    private var imagePicker = UIImagePickerController()
    var viewModel = UserViewModel()
    var storageDataViewModel = StorageDataViewModel()

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var photosBtn: UIButton!
    @IBOutlet weak var documentsBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dataCollectionView: UICollectionView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    private func resetComponentsToDefault() {
        self.activityIndicator.stopAnimating()
        self.dataCollectionView.isHidden = false
    }
    
    private func config() {
        title = "Home"
        self.navigationItem.hidesBackButton = true
        guard let user = userData as? User else {return}
        self.userNameLabel.text = user.displayName
        self.dataCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        addLayout()
        PhotosBtnAction(UIButton())
    }
    //
    //MARK: Upload data
    //
    @IBAction func uploadFileBtnAction(_ sender: Any) {
        docControllorConfig()
    }
    
    @IBAction func uploadImgBtnAction(_ sender: Any) {
        imagePickerControllerConfig()
    }
    //
    //MARK: Display File Btns Action
    //
    @IBAction func PhotosBtnAction(_ sender: Any) {
        self.photosBtn.backgroundColor = .lightGray
        self.documentsBtn.backgroundColor = .none
        self.documentsBtn.isEnabled = false
        self.dataCollectionView.isHidden = true
        self.activityIndicator.startAnimating()
        storageDataViewModel.getFile("Photos"){
            DispatchQueue.main.async {
                self.resetComponentsToDefault()
                self.dataCollectionView.reloadData()
                self.documentsBtn.isEnabled = true
            }
        }showNote: { [weak self] note,isFailed in
            self?.view.makeToast(note)
            if isFailed{
                self?.resetComponentsToDefault()
                self?.dataCollectionView.reloadData()
                self?.documentsBtn.isEnabled = true
            }
        }
        
    }
    
    @IBAction func documentsBtnAction(_ sender: Any) {
        self.documentsBtn.backgroundColor = .lightGray
        self.photosBtn.backgroundColor = .none
        self.photosBtn.isEnabled = false
        self.dataCollectionView.isHidden = true
        self.activityIndicator.startAnimating()
        storageDataViewModel.getFile("Documents"){
            DispatchQueue.main.async {
                self.resetComponentsToDefault()
                self.photosBtn.isEnabled = true
                self.dataCollectionView.reloadData()
            }
        }showNote: { [weak self] note,isFailed in
            self?.view.makeToast(note)
            if isFailed{
                self?.resetComponentsToDefault()
                self?.photosBtn.isEnabled = true
                self?.dataCollectionView.reloadData()
            }
        }
    }
    //
    //MARK: Sign Out
    //
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
//
//MARK: UIImagePickerControllerDelegate
//
extension HomeViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true) {
            let imageURL = info[UIImagePickerController.InfoKey.imageURL] as! URL
            self.dataCollectionView.isHidden = true
            self.activityIndicator.startAnimating()
            self.storageDataViewModel.uploadData(folderName: "Photos", dataName: imageURL.lastPathComponent, path: imageURL) {
                self.PhotosBtnAction(UIButton())
            }showNote: { [weak self] note,isFailed in
                self?.view.makeToast(note)
                if isFailed{
                    self?.resetComponentsToDefault()
                }
            }
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
//
//MARK: UIDocumentPickerDelegate
//
extension HomeViewController: UIDocumentPickerDelegate{
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let docURL = urls.first else {return}
        self.dataCollectionView.isHidden = true
        self.activityIndicator.startAnimating()
        self.storageDataViewModel.uploadData(folderName: "Documents", dataName: docURL.lastPathComponent, path: docURL) {
            self.documentsBtnAction(UIButton())
        }showNote: { [weak self] note,isFailed in
            self?.view.makeToast(note)
            if isFailed{
                self?.resetComponentsToDefault()
            }
        }
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
//
//MARK: UICollectionViewDataSource
//
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storageDataViewModel.filesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = dataCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell {
            let file = storageDataViewModel.filesArray[indexPath.row]
            cell.fetchData(file: file)
            return cell
        }
        return UICollectionViewCell()
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width/2-15
        let height = view.frame.height/3
        return CGSize(width: width, height: height)
    }
    
    private func addLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .vertical
        dataCollectionView?.collectionViewLayout = layout
    }
}
