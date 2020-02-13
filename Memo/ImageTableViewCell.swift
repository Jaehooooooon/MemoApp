//
//  ImageTableViewCell.swift
//  Memo
//
//  Created by 서재훈 on 2020/02/12.
//  Copyright © 2020 서재훈. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    static let identifier = "imageTableViewCell"
    
    @IBOutlet weak var memoImageView: UIImageView!
    var memoImage: UIImage?

    func update() {
        if let image = memoImage {
            self.memoImageView.image = image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
