//
//  BookCell.swift
//  BookList
//
//  Created by Amy Roberson on 2/1/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import UIKit

class BookCell: UITableViewCell {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    var bookID: String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateWithImage(nil)
    }
    
    func updateWithImage(_ image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            bookImage.image = imageToDisplay
        } else {
            spinner.startAnimating()
            bookImage.image = nil
        }
    }
    
    func update(_ imageResult: ImageResult) {
        switch imageResult {
        case .systemFailure(let error):
            print("failed to fetch image \(error)")
        case .httpFailure(let response):
            print("fail to fetch image: \(response)")
        case .success(let image):
            updateWithImage(image)
        }
    }
}
