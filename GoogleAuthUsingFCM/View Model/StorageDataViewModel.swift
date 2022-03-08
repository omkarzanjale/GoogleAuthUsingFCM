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
    
    typealias noteClosure = (String,Bool)->()
    typealias successClosure = ()->()
    //
    //MARK: Storage
    //
    func uploadData(folderName: String,dataName:String ,path: URL,complisherHandler: @escaping successClosure, showNote: @escaping noteClosure) {
        let photosRef = storageRef.child(folderName)
        let ref = photosRef.child(dataName)
        let uploadTask = ref.putFile(from: path, metadata: StorageMetadata()) { metadata, error in
            if error == nil {
                guard let _ = metadata else {
                    showNote("Unable to fetch file!",true)
                    return
                }
                print("File uploaded to Storage\\\(folderName)\\\(dataName)")
                complisherHandler()
            }else {
                showNote(error!.localizedDescription,true)
            }
        }
        uploadTask.observe(.progress) { progressStatus in
            guard let progress = progressStatus.progress else {return}
            let percentComplete = 100 * Int(progress.completedUnitCount)
                        / Int(progress.totalUnitCount)
            showNote("Uploading : \(percentComplete)%",false)
        }
    }
    
    func getFile(_ forType: String, complisherHandler: @escaping successClosure, showNote: @escaping noteClosure) {
        self.filesArray.removeAll()
        let ref = storageRef.child(forType)
        showNote("Getting files from Cloud Storage",false)
        ref.listAll { data, error in
            if data.items.count == 0 {
                showNote("Nothing is Storage please add files first",true)
            }else {
                for item in data.items {
                    ref.child(item.name).getMetadata { metadata, error in
                        if let _ = error {
                            showNote(error!.localizedDescription,true)
                        }else {
                            let path = item.fullPath
                            guard let fileType = metadata?.contentType else {
                                showNote("Invalid file type",true)
                                return
                            }
                            self.storageRef.child(path).downloadURL { url, err in
                                guard let url = url else {
                                    showNote("Unable to download file",true)
                                    return
                                }
                                let file = DataModel(URL: url, name: item.name, fileType: fileType)
                                self.filesArray.append(file)
                                complisherHandler()
                            }
                        }
                    }
                }
            }
        }
    }
}
