//
//  ImageDisplayViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 3/31/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

class ImageDisplayViewController: UIViewController {

    // MARK: UI Properties
    @IBOutlet var imageView: UIImageView!
    
    // MARK: Properties
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let img = image {
            imageView.image = img
        }
    }
    
    
    @IBAction func dismissImage(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
