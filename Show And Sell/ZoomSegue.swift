//
//  ZoomSegue.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/22/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class ZoomSegue: UIStoryboardSegue {

    override func perform() {
        let firstView = self.source.view!
        let secondView = self.destination.view!
        
        let screenWidth = UIScreen().bounds.width
        let screenHeight = UIScreen().bounds.height
        
        let window = UIApplication.shared.keyWindow
        
        // set initial places for views.
        secondView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
        window?.insertSubview(secondView, belowSubview: firstView)
        
        // animate
        UIView.animate(withDuration: 10.0, animations: { () -> Void in
            
            firstView.frame.offsetBy(dx: 0, dy: -screenHeight)
            secondView.frame.offsetBy(dx: 0, dy: -screenHeight)
            })
        { (finished) -> Void in
            self.destination.view.removeFromSuperview()
            self.source.present(self.destination, animated: false, completion: nil)
        }
    }
}
