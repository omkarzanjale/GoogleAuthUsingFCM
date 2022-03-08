//
//  StorageDataViewModel.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 08/03/22.
//

import Foundation
import UIKit
import FirebaseStorage

class StorageDataViewModel {
    
    var storageRef = Storage.storage().reference()
    var filesArray = [DataModel]()
    
    typealias failureClosure = ()->()
    typealias successClosure = ()->()
    
    //
    //MARK: Storage
    //
    func uploadData(folderName: String,dataName:String ,path: URL,complisherHandler: @escaping successClosure) {
        let photosRef = storageRef.child(folderName)
        
        let ref = photosRef.child(dataName)
        ref.putFile(from: path, metadata: StorageMetadata()) { metadata, error in
            if error == nil {
                guard let _ = metadata else {return}
                print("File uploaded to Storage\\\(folderName)\\\(dataName)")
                complisherHandler()
            }else {
                print("Error while uploading data to Storage : ")
                print(error!.localizedDescription)
            }
        }
    }
    
    func getFile(_ forType: String, complisherHandler: @escaping successClosure) {
        self.filesArray.removeAll()
        let ref = storageRef.child(forType)
        ref.listAll { storageRef, error in
            for image in storageRef.items {
                ref.child(image.name).getMetadata { metadata, error in
                    if let _ = error {
                        print(error!.localizedDescription)
                    }else {
                        let path = image.fullPath
                        guard let fileType = metadata?.contentType else {return}
                        print(fileType)
                        self.storageRef.child(path).downloadURL { url, err in
                            guard let url = url else {return}
                            
                            let file = DataModel(URL: url, name: image.name, fileType: fileType)
                            self.filesArray.append(file)
                            complisherHandler()
                        }
                    }
                }
            }
        }
    }
}
