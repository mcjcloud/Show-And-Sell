//
//  RateXIBView.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 4/25/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

protocol RateXIBViewDelegate {
    func rateXIBView(didSubmitRating rating: Int)
}

class RateXIBView: UIView {

    // MARK: UI Properties
    @IBOutlet var contentView: UIView!
    @IBOutlet var star1: UIButton!
    @IBOutlet var star2: UIButton!
    @IBOutlet var star3: UIButton!
    @IBOutlet var star4: UIButton!
    @IBOutlet var star5: UIButton!
    @IBOutlet var submitButton: UIButton!
    
    // MARK: Properties
    var buttons: [UIButton]!
    var parentView: UIView?
    var blurEffectView: UIVisualEffectView!
    var rating: Int = 0
    
    var delegate: RateXIBViewDelegate?
    
    init(parentView: UIView) {
        self.parentView = parentView
        let width = parentView.frame.width - 20
        let height = width * 0.35
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
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
        
        buttons = [star1, star2, star3, star4, star5]
        
        for button in buttons {
            button.addTarget(self, action: #selector(starPressed(_:)), for: .touchUpInside)
        }
        
        print("submit button: \(submitButton)")
        submitButton.setTitleColor(UIColor.gray, for: .disabled)
        submitButton.addTarget(self, action: #selector(rateGroup(_:)), for: .touchUpInside)
        updateSubmitButton()
    }
    
    func show(rating: Int) {
        if let view = parentView {
            self.contentView.clipsToBounds = true
            self.contentView.layer.cornerRadius = 10
            self.contentView.layer.zPosition = 1
            self.center = view.center
            self.contentView.alpha = 0.0
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            let touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(hide))
            touchRecognizer.cancelsTouchesInView = false
            blurEffectView.addGestureRecognizer(touchRecognizer)
            
            //always fill the view
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.alpha = 0.0
            
            view.addSubview(blurEffectView)
            view.addSubview(self)
            
            // fill rating stars
            for i in 0..<rating {
                buttons[i].setBackgroundImage(UIImage(named: "starfilled")!, for: .normal)
            }
            for i in rating..<buttons.count {
                buttons[i].setBackgroundImage(UIImage(named: "star")!, for: .normal)
            }
            
            UIView.animate(withDuration: 0.2) {
                self.contentView.alpha = 1.0
                self.blurEffectView.alpha = 1.0
            }
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.alpha = 0.0
            self.blurEffectView.alpha = 0.0
        }, completion: { finished in
            self.blurEffectView.removeFromSuperview()
            self.removeFromSuperview()
        })
    }
    
    // MARK: Button pressed
    
    func starPressed(_ button: UIButton!) {
        let index = Int(buttons.index(of: button)!)
        self.rating = index + 1
        
        for i in 0...index {
            buttons[i].setBackgroundImage(UIImage(named: "starfilled")!, for: .normal)
        }
        for i in (index + 1)..<buttons.count {
            buttons[i].setBackgroundImage(UIImage(named: "star")!, for: .normal)
        }
        
        updateSubmitButton()
    }
    
    func rateGroup(_ button: UIButton!) {
        print("rating group")
        delegate?.rateXIBView(didSubmitRating: self.rating)
        hide()
    }
    
    // MARK: Helper
    
    func updateSubmitButton() {
        submitButton.isEnabled = self.rating != 0
    }
}
