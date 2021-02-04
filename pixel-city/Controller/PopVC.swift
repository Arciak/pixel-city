//
//  PopVC.swift
//  pixel-city
//
//  Created by Artur Zarzecki on 04/02/2021.
//  Copyright © 2021 Artur Zarzecki. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var passedImage: UIImage!
    var titleText: String!
    
    func initData(forImage image: UIImage, photoTitle title: String) {
        self.passedImage = image
        self.titleText = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        titleLbl.text = titleText
        addDoubleTap()
    }
    
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }

}
