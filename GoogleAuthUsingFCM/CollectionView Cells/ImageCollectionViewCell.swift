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
        self.img.image = UIImage(named: "Gallery")
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
            self.img.tintColor = .black
            self.img.contentMode = .scaleAspectFit
            self.img.image = UIImage(systemName: "doc")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
