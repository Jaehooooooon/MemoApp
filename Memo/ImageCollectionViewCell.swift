//
//  ImageCollectionViewCell.swift
//  Memo
//
//  Created by 서재훈 on 2020/02/13.
//  Copyright © 2020 서재훈. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    static let identifier = "imageCollectionViewCell"
    
    @IBOutlet weak var memoImageView: UIImageView!
    var memoImage: UIImage?

    func update() {
        if let image = memoImage {
            self.memoImageView.image = image
        }
    }
}
