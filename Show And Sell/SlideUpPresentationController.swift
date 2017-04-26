//
//  SlideUpPresentationController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 4/4/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

class SlideUpPresentationController: UIPresentationController {
    
    // MARK: Properties
    fileprivate var dimmingView: UIView!
    var heightScale: CGFloat
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        
        frame.origin.x = 0
        frame.origin.y = containerView!.frame.height - (containerView!.frame.height * heightScale)
    
        print("frameOfPresentedViewInContainerView: \(frame)")
        return frame
    }
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, heightScale: CGFloat) {
        self.heightScale = heightScale
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        // setup dimming
        setupDimmingView()
    }
    
    // MARK: Presentation
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
        
        // TODO: attemp to draw shadow here
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        
        print("parent size: \(parentSize)")
        return CGSize(width: parentSize.width, height: parentSize.height * heightScale)
    }
    
    // MARK: handle dismiss
    private func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        dimmingView.alpha = 0.0
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
    }
    
    dynamic func handleTap(recognizer: UITapGestureRecognizer) {
        dimmingView.removeFromSuperview()
        presentingViewController.dismiss(animated: true)
    }
}
