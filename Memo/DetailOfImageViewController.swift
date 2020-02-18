//
//  DetailOfImageViewController.swift
//  Memo
//
//  Created by 서재훈 on 2020/02/18.
//  Copyright © 2020 서재훈. All rights reserved.
//

import UIKit

class DetailOfImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = self.image {
            imageView.image = image
        }
        
        self.imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.view.backgroundColor = UIColor.black
    }

    //ImageView의 TabGesture이벤트를 처리한다.
    @objc func buttonTapped(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            print("tap")
            self.navigationController?.navigationBar.isHidden = false
            self.tabBarController?.tabBar.isHidden = false
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
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
