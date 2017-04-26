//
//  RateXIBView.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 4/25/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

class RateXIBView: UIView {

    // MARK: UI Properties
    @IBOutlet var contentView: UIView!
    @IBOutlet var star1: UIButton!
    @IBOutlet var star2: UIButton!
    @IBOutlet var star3: UIButton!
    @IBOutlet var star4: UIButton!
    @IBOutlet var star5: UIButton!
    
    var parentView: UIView?
    
    init(parentView: UIView) {
        self.parentView = parentView
        let frame = CGRect(x: 0, y: 0, width: parentView.frame.width - 30, height: 150)
        
        super.init(frame: frame)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        Bundle.main.loadNibNamed("RateXIB", owner: self, options: nil)
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
    }
    
    func show() {
        if let view = parentView {
            //self.contentView.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
            self.contentView.clipsToBounds = true
            self.contentView.layer.cornerRadius = 10
            self.contentView.layer.zPosition = 1
            
            self.center = view.center
            view.addSubview(self)
        }
    }
}
