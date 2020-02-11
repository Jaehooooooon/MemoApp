//
//  DetailOfMemoViewController.swift
//  Memo
//
//  Created by 서재훈 on 2020/02/10.
//  Copyright © 2020 서재훈. All rights reserved.
//

import UIKit

class DetailOfMemoViewController: UIViewController {
    @IBOutlet weak var memoTableView: UITableView!
    var memo: Memo?
    
    var token: NSObjectProtocol?
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination.children.first as? NewMemoViewController {
            vc.editTarget = memo
        }
    }
    
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        token = NotificationCenter.default.addObserver(forName: NewMemoViewController.memoDidChange, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            self?.memoTableView.reloadData()
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailOfMemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleOfMemoCell", for: indexPath)
            cell.textLabel?.text = memo?.title
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContentOfMemoCell", for: indexPath)
            cell.textLabel?.text = memo?.content
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateOfMemoCell", for: indexPath)
            cell.textLabel?.text = formatter.string(for: memo?.insertDate)
            return cell
        default:
            fatalError()
        }
    }
}
