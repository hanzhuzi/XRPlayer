//
//  XRHorizontalSwipeInteractionAnimator.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/11/28.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 - 手势交互转场(Left to Right)
 - @by  黯丶野火
 */

import UIKit

private var panGestureRecognizerKey: Int = 40001

class XRHorizontalSwipeInteractionAnimator: XRBaseInteractionAnimator {
    
    open var popOnLeftToRight: Bool = true
    fileprivate var transitionComplete: Bool = false
    open var interactionOperation: XRInteractionOperation = .Pop
    fileprivate var viewController: UIViewController?
    
    override var completionSpeed: CGFloat {
        get {
            return 1.0 - self.percentComplete
        }
        
        set {
            
        }
    }
    
    override func wireToViewController(targetViewController: UIViewController, operation: XRInteractionOperation) {
        
        self.popOnLeftToRight = true
        interactionOperation = operation
        viewController = targetViewController
        self.addGestureRecognizerInView(view: viewController!.view)
    }
    
    func addGestureRecognizerInView(view: UIView) {
        
        var panGesture = objc_getAssociatedObject(view, &panGestureRecognizerKey)
        
        if panGesture != nil {
            view.removeGestureRecognizer(panGesture as! UIGestureRecognizer)
            panGesture = nil
        }
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture(pan:)))
        view.addGestureRecognizer(panGesture as! UIGestureRecognizer)
        objc_setAssociatedObject(view, &panGestureRecognizerKey, panGesture, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /**
     - 手势驱动
     */
    func handleGesture(pan: UIPanGestureRecognizer) {
        
        let translation = pan.translation(in: pan.view?.superview)
        let velocity    = pan.velocity(in: pan.view)
        
        switch pan.state {
        case .began:
            let leftToRightSwipe = velocity.x > 0
            
            if interactionOperation == .Pop {
                // Pop操作，left to right
                if (popOnLeftToRight && leftToRightSwipe) || (!popOnLeftToRight && !leftToRightSwipe) {
                    self.interactionInProgress = true
                    let _ = viewController?.navigationController?.popViewController(animated: true)
                }
            }
            else if interactionOperation == .Tab {
            
            }
            else if interactionOperation == .Dismiss {
                self.interactionInProgress = true
                viewController?.dismiss(animated: true, completion: nil)
            }
        case .changed:
            if interactionInProgress {
                var fraction = translation.x / 200.0
                fraction = fraction < 0.0 ? -fraction : fraction
                fraction = fraction < 0.0 ? 0.0 : fraction
                fraction = fraction > 1.0 ? 1.0 : fraction
                
                transitionComplete = fraction > 0.5
                if fraction >= 1.0 {
                    fraction = 0.99
                }
                self.update(fraction)
            }
        case .ended, .cancelled:
            if interactionInProgress {
                interactionInProgress = false
                if !transitionComplete || pan.state == .cancelled {
                    self.cancel()
                }
                else {
                    self.finish()
                }
            }
            
        default:
            break
        }
    }
    
    
    
}
