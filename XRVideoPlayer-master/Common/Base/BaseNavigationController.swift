//
//  BaseNavigationController.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/11/18.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController , UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
        self.navigationBar.isTranslucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.interactivePopGestureRecognizer != nil {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
//    func wirePopInteractionAnimationToViewController(viewController: UIViewController) {
//        
//        if let hPopInteractionAnimator = (UIApplication.shared.delegate as! AppDelegate).hPopInteractionAnimator {
//            hPopInteractionAnimator.popOnLeftToRight = false
//            hPopInteractionAnimator.wireToViewController(targetViewController: viewController, operation: .Pop)
//        }
//    }
//    
//    // MARK: - UINavigationControllerDelegate
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        
//        self.wirePopInteractionAnimationToViewController(viewController: viewController)
//    }
//    
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        
//    }
//    
//    // 转场动画统一控制 PUSH \ POP
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        if let sunKenAnimator = (UIApplication.shared.delegate as! AppDelegate).sunKenAnimator {
//            if fromVC is HttpStreamPlayViewController && toVC is VideoPlayViewController {
//                sunKenAnimator.isReverse = false
//                return sunKenAnimator
//            }
//            else if fromVC is VideoPlayViewController && toVC is HttpStreamPlayViewController {
//                sunKenAnimator.isReverse = true
//                return sunKenAnimator
//            }
//        }
//        
//        return nil
//    }
//    
//    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        
//        if let hInteractionAnimator = (UIApplication.shared.delegate as! AppDelegate).hPopInteractionAnimator , hInteractionAnimator.interactionInProgress {
//            return hInteractionAnimator
//        }
//        
//        return nil
//    }
//    
//    // MARK: - UIViewControllerTransitionDelegate
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        return nil
//    }
//    
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        return nil
//    }

    
    
}
