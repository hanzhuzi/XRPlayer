//
//  XRBaseTransitionAnimator.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/11/28.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 - 转场动画
 - Base Class
 - @by  黯丶野火
 */

import UIKit

class XRBaseTransitionAnimator: NSObject , UIViewControllerAnimatedTransitioning {
    
    var isReverse: Bool = false
    var duration:  TimeInterval = 1.0
    
    /**
     - 子类需要重写该方法，以自定制需要的转场动画
     */
    func animatedTransition(transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController , toVC: UIViewController , fromView: UIView? , toView: UIView?) {
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC   = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        guard let from = fromVC , let to = toVC else {
            return
        }
        
        let fromView = from.view
        let toView   = to.view
        self.animatedTransition(transitionContext: transitionContext, fromVC: from, toVC: to, fromView: fromView, toView: toView)
    }
    
}
