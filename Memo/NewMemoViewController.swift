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
    
    var editTarget: Memo?
    var originalMemoContent: String?
    
    var willShowToken: NSObjectProtocol?
    var willHideToken: NSObjectProtocol?
    
    //MARK:-
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
        
        if let memo = editTarget {
            navigationItem.title = "메모 편집"
            titleTextField.text = memo.title
            contentTextView.textColor = UIColor.black
            contentTextView.text = memo.content
            originalMemoContent = memo.content
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
    
    @IBAction func save() {
        guard let content = contentTextView.text, content.count > 0, content != "메모" else {
            alert(message: "메모를 입력하세요")
            return
        }
        var title = titleTextField.text
        if title == "" { title = "무제" }
        
        //        let newMemo = Memo(title: title!, content: memo)
        //        Memo.dummyMemoList.append(newMemo)
        if let target = editTarget {
            target.title = title
            target.content = content
            DataManager.shared.saveContext()
            NotificationCenter.default.post(name: NewMemoViewController.memoDidChange, object: nil)
        } else {
            DataManager.shared.addNewMemo(title, content)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewSetting() {
        if contentTextView.text == "메모" {
            contentTextView.text = ""
            contentTextView.textColor = UIColor.black
        } else if contentTextView.text == "" {
            contentTextView.text = "메모"
            contentTextView.textColor = UIColor.lightGray
        }
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

extension NewMemoViewController {
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}
