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
    
    open override var shouldAutorotate: Bool {
        
        return self.visibleViewController != nil ? self.visibleViewController!.shouldAutorotate : false
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if let visibleVc = self.visibleViewController {
            return visibleVc.supportedInterfaceOrientations
        }
        
        return .all
    }
    
    open override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        if let visibleVc = self.visibleViewController {
            return visibleVc.preferredInterfaceOrientationForPresentation
        }
        
        return .portrait
    }
}

