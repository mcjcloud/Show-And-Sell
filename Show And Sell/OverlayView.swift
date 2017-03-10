//
//  self.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 2/19/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

class OverlayView: UIView {
    
    enum OverlayType {
        case complete, failed, loading
    }

    private var activityIndicator: UIActivityIndicatorView?

    init(type: OverlayType, text: String?) {
        
        switch type {
        case .loading:
            super.init(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
            activityIndicator = UIActivityIndicatorView()
            activityIndicator!.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            //activityIndicator!.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            activityIndicator!.center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height * 0.5)
            activityIndicator!.activityIndicatorViewStyle = .whiteLarge
            self.addSubview(activityIndicator!)
        case .complete:
            super.init(frame: CGRect(x: 0, y: 0, width: 180, height: 180))
            let imageView = UIImageView(image: UIImage(named: "green-check"))
            imageView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            imageView.center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height * 0.5)
            self.addSubview(imageView)
        case .failed:
            super.init(frame: CGRect(x: 0, y: 0, width: 180, height: 180))
            let imageView = UIImageView(image: UIImage(named: "red-x"))
            imageView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            imageView.center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height * 0.5)
            self.addSubview(imageView)
        }
        
        // set the text if there is text
        if let message = text {
            let messageLabel = UILabel()
            messageLabel.frame = CGRect(x: 0, y: self.center.y + 30, width: self.frame.width, height: 60)
            messageLabel.textAlignment = .center
            messageLabel.adjustsFontSizeToFitWidth = true
            messageLabel.textColor = UIColor.darkText
            messageLabel.text = message
            self.addSubview(messageLabel)
        }
        else {
            print("MESSAGE NOT AVAILABLE")
        }
        
        
        self.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.layer.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showOverlay(view: UIView) {
        // if the given view is a tableview, then add the contentOffset back to make the overlay centered
        self.center = CGPoint(x: view.center.x, y: view.center.y + ((view as? UITableView)?.contentOffset.y ?? 0))
        view.addSubview(self)
        activityIndicator?.startAnimating()
    }
    
    func showAnimatedOverlay(view: UIView) {
        // if the given view is a tableview, then add the contentOffset back to make the overlay centered
        self.center = CGPoint(x: view.center.x, y: view.center.y + ((view as? UITableView)?.contentOffset.y ?? 0))
        view.addSubview(self)
        activityIndicator?.startAnimating()
        
        UIView.animate(withDuration: 2.0, delay: 1.0, animations: { self.alpha = 0.0 }) { animated in
            DispatchQueue.main.async {
                self.hideOverlayView()
            }
        }
    }
    
    func hideOverlayView() {
        activityIndicator?.stopAnimating()
        self.removeFromSuperview()
    }
}
