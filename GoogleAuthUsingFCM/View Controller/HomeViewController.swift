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
    @IBOutlet weak var dataCollectionView: UICollectionView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
        storageDataViewModel.getFile("Documents"){
            DispatchQueue.main.async {
                self.dataCollectionView.reloadData()
            }
        }
    }
    
    private func config() {
        title = "Home"
        self.navigationItem.hidesBackButton = true
        guard let user = userData as? User else {return}
        self.userNameLabel.text = user.displayName
        self.dataCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        addLayout()
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
//
//MARK: UIImagePickerControllerDelegate
//
extension HomeViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true) {
            let imageURL = info[UIImagePickerController.InfoKey.imageURL] as! URL
            self.storageDataViewModel.uploadData(folderName: "Photos", dataName: imageURL.lastPathComponent, path: imageURL) {
                self.storageDataViewModel.getFile("Photos"){
                    DispatchQueue.main.async {
                        self.dataCollectionView.reloadData()
                    }
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
        self.storageDataViewModel.uploadData(folderName: "Documents", dataName: docURL.lastPathComponent, path: docURL) {
            self.storageDataViewModel.getFile("Documents"){
                DispatchQueue.main.async {
                    self.dataCollectionView.reloadData()
                }
            }
        }
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
//
//MARK: Download Image
//
extension UIImageView {
    
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
