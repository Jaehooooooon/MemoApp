//
//  NewMemoViewController.swift
//  Memo
//
//  Created by 서재훈 on 2020/02/10.
//  Copyright © 2020 서재훈. All rights reserved.
//

import UIKit

class NewMemoViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var editTarget: Memo?
    var originalMemoContent: String?
    var originalImages: [UIImage] = []
    
    var willShowToken: NSObjectProtocol?
    var willHideToken: NSObjectProtocol?
    
    //MARK:- Setting
    deinit {
        if let token = willShowToken {
            NotificationCenter.default.removeObserver(token)
        }
        if let token = willHideToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        if let memo = editTarget {
            navigationItem.title = "메모 편집"
            titleTextField.text = memo.title
            contentTextView.text = memo.content
            originalMemoContent = memo.content
            
            if let images = memo.images {
                do {
                    let mySavedData = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self], from: images) as? NSArray
                    if let mySavedData = mySavedData {
                        for data in mySavedData {
                            let image = UIImage(data: data as! Data)
                            if let image = image {
                                originalImages.append(image)
                                print("image is appended")
                            } else { print("unarchived image is nil") }
                        }
                    } else {
                        print("mySavedData is nil")
                    }
                } catch {
                    print("unarchived error : ",error)
                }
            }
        } else {
            navigationItem.title = "새 메모"
        }
        
        contentTextView.delegate = self
        
        willShowToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            guard let strongSelf = self else { return }
            
            if let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let height = frame.cgRectValue.height
                var inset = strongSelf.contentTextView.contentInset
                inset.bottom = height
                strongSelf.contentTextView.contentInset = inset
                
                inset = strongSelf.contentTextView.verticalScrollIndicatorInsets
                inset.bottom = height
                strongSelf.contentTextView.verticalScrollIndicatorInsets = inset
            }
        })
        
        willHideToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            guard let strongSelf = self else { return }
            
            var inset = strongSelf.contentTextView.contentInset
            inset.bottom = 0
            strongSelf.contentTextView.contentInset = inset
            
            inset = strongSelf.contentTextView.verticalScrollIndicatorInsets
            inset.bottom = 0
            strongSelf.contentTextView.verticalScrollIndicatorInsets = inset
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contentTextView.becomeFirstResponder()
        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        contentTextView.resignFirstResponder()
        navigationController?.presentationController?.delegate = nil
    }
    
    //MARK:- Memo
    @IBAction func save() {
        guard let content = contentTextView.text, content.count > 0, content != "메모" else {
            alert(message: "메모를 입력하세요")
            return
        }
        var title = titleTextField.text
        if title == "" { title = "무제" }
        
        if let target = editTarget {    //메모 편집본
            target.title = title
            target.content = content
            
            let CDataArray = NSMutableArray();
            for img in originalImages{
                let data : NSData = NSData(data: img.pngData()!)
                CDataArray.add(data)
            }
            do {
                let coreDataObject = try NSKeyedArchiver.archivedData(withRootObject: CDataArray, requiringSecureCoding: false)
                target.images = coreDataObject
            } catch {
                target.images = nil
            }
            DataManager.shared.saveContext()
            NotificationCenter.default.post(name: NewMemoViewController.memoDidChange, object: nil)
        } else {    //새 메모
            DataManager.shared.addNewMemo(title, content, self.originalImages)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewSetting() {
        if contentTextView.text == "메모" {
            contentTextView.text = ""
            contentTextView.textColor = UIColor.label
        } else if contentTextView.text == "" {
            contentTextView.text = "메모"
            contentTextView.textColor = UIColor.lightGray
        }
    }
    
    //MARK:- Image
    @IBAction func newImage(_ sender: Any) {
        let actionSheet = UIAlertController(title: "New Image", message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { action in
            let CameraPicker = UIImagePickerController()
            CameraPicker.delegate = self
            CameraPicker.sourceType = .camera
            self.present(CameraPicker, animated: true, completion: nil)
        })
        let album = UIAlertAction(title: "Photos", style: .default, handler: { action in
            let CameraPicker = UIImagePickerController()
            CameraPicker.delegate = self
            CameraPicker.sourceType = .photoLibrary
            self.present(CameraPicker, animated: true, completion: nil)
        })
        let imageUrl = UIAlertAction(title: "URL", style: .default) { (action) in
            let textAlert = UIAlertController(title: "입력", message: nil, preferredStyle: .alert)
            textAlert.addTextField { (textField) in
                textField.placeholder = "URL"
            }
            let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
                if let text = textAlert.textFields?[0].text, text.count > 0 {
                        DispatchQueue.global().async {
                            guard let imageURL: URL = URL(string: text) else {
                                DispatchQueue.main.async {
                                    self.alert(message: "URL이 유효하지 않습니다")
                                }
                                print("text가 유효하지 않음")
                                return
                            }
                            guard let imageData: Data = try? Data(contentsOf: imageURL) else {
                                DispatchQueue.main.async {
                                    self.alert(message: "URL이 유효하지 않습니다")
                                }
                                print("url이 유효하지 않음")
                                return
                            }
                            DispatchQueue.main.async {
                                if let image = UIImage(data: imageData) {
                                    self.originalImages.append(image)
                                    self.imageCollectionView.reloadData()
                                } else {
                                    self.alert(message: "URL이 유효하지 않습니다")
                                }
                            }
                        }
                } else {
                    self.alert(message: "URL을 입력하세요")
                }
            }
            let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            textAlert.addAction(cancel)
            textAlert.addAction(ok)
            
            self.present(textAlert, animated: true, completion: nil)
        }
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.originalImages.remove(at: 0)
            self.imageCollectionView.reloadData()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(camera)
        actionSheet.addAction(album)
        actionSheet.addAction(imageUrl)
        if (self.originalImages.count != 0) { actionSheet.addAction(delete) }
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
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

//MARK:- Extension
// ImagePicker
extension NewMemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("add image")
            self.originalImages.append(originalImage)
        }
        self.imageCollectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}

// TextView
extension NewMemoViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let original = originalMemoContent, let edited = textView.text {
            if #available(iOS 13.0, *) {
                isModalInPresentation = original != edited
            } else {
                
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewSetting()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text == "" {
            textViewSetting()
        }
    }
}

// Modal attempt to dismiss
extension NewMemoViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alert = UIAlertController(title: "알림", message: "편집한 내용을 저장할까요?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] (action) in
            self?.save()
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] (action) in
            self?.cancel()
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

// Notification
extension NewMemoViewController {
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}

// CollectionView
extension NewMemoViewController: UICollectionViewDataSource {
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
