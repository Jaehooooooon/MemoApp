//
//  ListOfMemoTableViewCell.swift
//  Memo
//
//  Created by 서재훈 on 2020/02/10.
//  Copyright © 2020 서재훈. All rights reserved.
//

import UIKit

class ListOfMemoTableViewCell: UITableViewCell {
    static let identifier = "ListOfMemoCell"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    let dateFormatter = DateFormatter()
    var thumbnailImage: UIImage?
    
    var memo: Memo?
    
    func update() {
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        if self.memo != nil {
            titleLabel.text = self.memo?.title
            subtitleLabel.text = self.memo?.content
            
            if let images = memo!.images {
                do {
                    let mySavedData = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self], from: images) as? NSArray
                    if let mySavedData = mySavedData, mySavedData.count > 0 {
                        let data = mySavedData[0]
                        let image = UIImage(data: data as! Data)
                        if let image = image {
                            DispatchQueue.main.async {
                                self.thumbnailImageView.image = image
                            }
                        } else {
                            print("unarchived image is nil")
                        }
                    } else {
                        print("mySavedData is nil")
                    }
                } catch {
                    print("unarchived error : ",error)
                }
            }
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
