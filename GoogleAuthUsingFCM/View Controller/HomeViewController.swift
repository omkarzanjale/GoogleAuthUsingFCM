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
    var storageDataViewModel = StorageDataViewModel()

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dataCollectionView: UICollectionView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    private func resetComponentsToDefault() {
        self.activityIndicator.stopAnimating()
        self.dataCollectionView.isHidden = false
        self.segmentedControl.isEnabled = true
    }
    
    private func config() {
        title = "Home"
        self.navigationItem.hidesBackButton = true
        guard let user = userData as? User else {return}
        self.userNameLabel.text = user.displayName
        self.dataCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        self.addLayout()
        self.uploadNewFile()
        self.segmentedControl.selectedSegmentIndex = 0
        self.segentedControlAction(nil)
    }
    //
    //MARK: Upload new files
    //
    private func uploadNewFile() {
        let uploadImageMenu = UIAction(title: "Photo", image: UIImage(systemName: "photo.on.rectangle.angled"), identifier: nil) { _ in
            self.imagePickerControllerConfig()
        }
        let uploadFileMenu = UIAction(title: "File", image: UIImage(systemName: "doc.badge.plus"), identifier: nil) { _ in
            self.docControllorConfig()
        }
        let uploadMenus = UIMenu(title: "", image: nil, identifier: nil, children: [uploadImageMenu,uploadFileMenu])
        self.uploadBtn.menu = uploadMenus
        self.uploadBtn.showsMenuAsPrimaryAction = true
    }
    //
    //MARK: Get Files
    //
    private func getFiles(for identifier: String) {
        self.segmentedControl.isEnabled = false
        self.dataCollectionView.isHidden = true
        self.activityIndicator.startAnimating()
        storageDataViewModel.getFile(identifier){
            DispatchQueue.main.async {
                self.resetComponentsToDefault()
                self.dataCollectionView.reloadData()
            }
        }showNote: { [weak self] note,isFailed in
            self?.view.makeToast(note)
            if isFailed{
                self?.resetComponentsToDefault()
                self?.dataCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func segentedControlAction(_ sender: Any?) {
        if segmentedControl.selectedSegmentIndex == 0{
            if self.storageDataViewModel.photosArray.isEmpty{
                self.getFiles(for: "Photos")
            }else {
                self.dataCollectionView.reloadData()
            }
        }else {
            if self.storageDataViewModel.filesArray.isEmpty {
                self.getFiles(for: "Documents")
            }else {
                self.dataCollectionView.reloadData()
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
            self.storageDataViewModel.uploadData(folderName: "Photos", dataName: imageURL.lastPathComponent, path: imageURL) { indexPath in
                DispatchQueue.main.async {
                    self.dataCollectionView.reloadItems(at: [indexPath])
                }
            } showNote: {[weak self] note, isFailed in
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
        self.storageDataViewModel.uploadData(folderName: "Documents", dataName: docURL.lastPathComponent, path: docURL) { indexPath in
            DispatchQueue.main.async {
                self.dataCollectionView.reloadItems(at: [indexPath])
            }
        } showNote: {[weak self] note, isFailed in
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
        if segmentedControl.selectedSegmentIndex == 0 {
            return storageDataViewModel.photosArray.count
        }
        return storageDataViewModel.filesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = dataCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell {
            if segmentedControl.selectedSegmentIndex == 0{
                let file = storageDataViewModel.photosArray[indexPath.row]
                cell.fetchData(file: file)
            }else {
                let file = storageDataViewModel.filesArray[indexPath.row]
                cell.fetchData(file: file)
            }
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
