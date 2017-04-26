//
//  SlideUpPresentationManager.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 4/4/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

extension SlideUpPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideUpPresentationController(presentedViewController: presented,
                                                                   presenting: presenting,
                                                                   heightScale: 0.8)
        return presentationController
    }
}

class SlideUpPresentationManager: NSObject {

}
