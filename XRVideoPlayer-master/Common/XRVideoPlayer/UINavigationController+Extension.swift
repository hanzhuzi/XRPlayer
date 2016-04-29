//
//  UINavigationController+Extension.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/28.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  处理当控制器的容器是导航控制器时的屏幕旋转控制
 */

import Foundation
import UIKit

extension UINavigationController {
    
    public override func shouldAutorotate() -> Bool {
        if let lastVc = self.viewControllers.last {
            lastVc.shouldAutorotate()
        }
        return false
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let lastVc = self.viewControllers.last {
            return lastVc.supportedInterfaceOrientations()
        }
        
        return .All
    }
    
    public override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        if let lastVc = self.viewControllers.last {
            return lastVc.preferredInterfaceOrientationForPresentation()
        }
        
        return .Portrait
    }
}

