//
//  XRBaseInteractionAnimator.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/11/28.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 - 交互式转场动画
 - @by  黯丶野火
 */

import UIKit

public enum XRInteractionOperation {
    
    case Pop
    case Dismiss
    case Tab
}

class XRBaseInteractionAnimator: UIPercentDrivenInteractiveTransition {
    
    open var interactionInProgress: Bool = false
    
    /**
     - 子类需要重写
     */
    func wireToViewController(targetViewController: UIViewController , operation: XRInteractionOperation ) {
        
    }
    
}
