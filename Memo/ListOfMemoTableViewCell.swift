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
    let dateFormatter = DateFormatter()
    
    var memo: Memo?
    
    func update() {
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        if self.memo != nil {
            titleLabel.text = self.memo?.title
            subtitleLabel.text = dateFormatter.string(for: self.memo!.insertDate)
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
