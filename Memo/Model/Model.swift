//
//  Model.swift
//  Memo
//
//  Created by 서재훈 on 2020/02/10.
//  Copyright © 2020 서재훈. All rights reserved.
//

import Foundation

class Memo {
    var title: String
    var content: String
    var insertDate: Date
    
    init(title:String, content: String) {
        self.title = title
        self.content = content
        insertDate = Date()
    }
    
    static var dummyMemoList = [
        Memo(title: "메모1", content: "👍🏻"),
        Memo(title: "메모2", content: "❤️")
    ]
}
