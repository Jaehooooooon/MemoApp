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
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var memo: Memo?
    var originalImages: [UIImage] = []
    var token: NSObjectProtocol?
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    
    //MARK:-
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegueIdentifier" {
            if let vc = segue.destination.children.first as? NewMemoViewController {
                vc.editTarget = memo
            }
        } else if segue.identifier == "imageSegueIdentifier" {
            if let vc = segue.destination as? DetailOfImageViewController {
                guard let cell: ImageCollectionViewCell = sender as? ImageCollectionViewCell else {
                    return
                }
                vc.image = cell.memoImage
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let layout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        imageSetting()
        
        token = NotificationCenter.default.addObserver(forName: NewMemoViewController.memoDidChange, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            self?.memoTableView.reloadData()
            self?.originalImages.removeAll()
            self?.imageSetting()
            self?.imageCollectionView.reloadData()
        })
    }
    
    func imageSetting() {
        if let memo = memo {
            if let images = memo.images {
                do {
                    let mySavedData = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self], from: images) as? NSArray
                    if let mySavedData = mySavedData {
                        for data in mySavedData {
                            let image = UIImage(data: data as! Data)
                            if let image = image {
                                originalImages.append(image)
                            } else { print("unarchived image is nil") }
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
    
    @IBAction func deleteMemo(_ sender: Any) {
        let alert = UIAlertController(title: "삭제 확인", message: "메모를 삭제할까요?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] (action) in
            DataManager.shared.deleteMemo(self?.memo)
            self?.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
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

extension DetailOfMemoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.originalImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
        cell.memoImage = self.originalImages[indexPath.row]
        cell.update()
        return cell
    }
}
