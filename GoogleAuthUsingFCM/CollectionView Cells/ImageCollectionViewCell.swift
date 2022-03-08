//
//  ImageCollectionViewCell.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 08/03/22.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblFileName: UILabel!
    
    func fetchData(file: DataModel) {
        self.lblFileName.text = file.name
        self.img.contentMode = .redraw
        switch file.fileType {
        case "image/jpeg" :
            self.img.downloaded(from: file.URL)
            break
        case "application/zip" :
            self.img.image = UIImage(named: "ZIP")
            break
        case "application/pdf" :
            self.img.image = UIImage(named: "PDF")
            break
        case "application/docx" :
            self.img.image = UIImage(named: "DOCX")
            break
        default:
            self.img.image = UIImage(systemName: "doc")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
