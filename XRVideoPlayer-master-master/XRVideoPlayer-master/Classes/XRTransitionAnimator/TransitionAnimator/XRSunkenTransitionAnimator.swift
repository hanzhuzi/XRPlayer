//
//  XRSunkenTransitionAnimator.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/11/28.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 - 凹陷转场动画 (仿酷狗音乐转场动画)
 - @by 黯丶野火
 */

import UIKit

class XRSunkenTransitionAnimator: XRBaseTransitionAnimator {
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    override func animatedTransition(transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController, fromView: UIView?, toView: UIView?) {
        
        if isReverse {
            self.excuteBackwordsAnimationTransition(transitionContext: transitionContext, fromVC: fromVC, toVC: toVC, fromView: fromView, toView: toView)
        }
        else {
            self.excuteForwordsAnimationTransition(transitionContext: transitionContext, fromVC: fromVC, toVC: toVC, fromView: fromView, toView: toView)
        }
    }
    
    /**
     - 正向动画 push \ present
     */
    func excuteForwordsAnimationTransition(transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController, fromView: UIView?, toView: UIView?) {
        
        let containerView = transitionContext.containerView
        containerView.backgroundColor = UIColor.black
        
        let mainSize = UIScreen.main.bounds.size
        
        containerView.addSubview(fromView!)
        containerView.addSubview(toView!)
        
        fromView?.frame = CGRect(x: 0, y: 0, width: mainSize.width, height: mainSize.height)
        toView?.frame = CGRect(x: mainSize.width, y: 0, width: mainSize.width, height: mainSize.height)
        
        UIView.animateKeyframes(withDuration: self.transitionDuration(using: transitionContext),
                                delay: 0.0,
                                options: UIViewKeyframeAnimationOptions.calculationModeCubic,
                                animations: { 
                                    
                                fromView?.frame = CGRect(x: 20.0, y: 20.0, width: mainSize.width, height: mainSize.height - 40.0)
                                toView?.frame = CGRect(x: 0, y: 0, width: mainSize.width, height: mainSize.height)
                                    
        }) { (completed) in
            if transitionContext.transitionWasCancelled {
                fromView?.removeFromSuperview()
                fromView?.frame = CGRect(x: 0, y: 0, width: mainSize.width, height: mainSize.height)
                toView?.frame   = CGRect(x: mainSize.width, y: 0, width: mainSize.width, height: mainSize.height)
            }
            else {
                // 重新设置转场后的from和to的frame
                fromView?.removeFromSuperview()
                fromView?.frame = CGRect(x: 20.0, y: 20.0, width: mainSize.width, height: mainSize.height - 40.0)
                toView?.frame = CGRect(x: 0, y: 0, width: mainSize.width, height: mainSize.height)
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
    
    /**
     - 反转动画 pop \ dismiss
     */
    func excuteBackwordsAnimationTransition(transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController, fromView: UIView?, toView: UIView?) {
        
        let containerView = transitionContext.containerView
        containerView.backgroundColor = UIColor.black
        containerView.addSubview(toView!)
        containerView.addSubview(fromView!)
        
        let mainSize = UIScreen.main.bounds.size
        fromView?.frame = CGRect(x: 0, y: 0, width: mainSize.width, height: mainSize.height)
        toView?.frame = CGRect(x: 20.0, y: 20.0, width: mainSize.width, height: mainSize.height - 40.0)
        
        UIView.animateKeyframes(withDuration: self.transitionDuration(using: transitionContext),
                                delay: 0.0,
                                options: UIViewKeyframeAnimationOptions.calculationModeCubic,
                                animations: {
                                    
                                    fromView?.frame = CGRect(x: mainSize.width, y: 0.0, width: mainSize.width, height: mainSize.height)
                                    toView?.frame = CGRect(x: 0, y: 0, width: mainSize.width, height: mainSize.height)
                                    
        }) { (completed) in
            if transitionContext.transitionWasCancelled {
                fromView?.frame = CGRect(x: 0, y: 0, width: mainSize.width, height: mainSize.height)
                toView?.frame = CGRect(x: 20.0, y: 20.0, width: mainSize.width, height: mainSize.height - 40.0)
            }
            else {
                // 重新设置转场后的from和to的frame
                fromView?.removeFromSuperview()
                fromView?.frame = CGRect(x: mainSize.width, y: 0.0, width: mainSize.width, height: mainSize.height)
                toView?.frame = CGRect(x: 0, y: 0, width: mainSize.width, height: mainSize.height)
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
    
}
