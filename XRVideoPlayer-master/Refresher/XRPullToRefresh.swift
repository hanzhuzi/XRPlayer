//
//  XRPullToRefresh.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 17/6/22.
//  Copyright © 2017年 黯丶野火. All rights reserved.
//
// 自定义下拉刷新

import UIKit

extension UIScrollView {
    
    func customAddRefresh(action: @escaping (() -> ())) {
        
        let animator = XRAnimator(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: XRAnimator.defaultViewHeight))
        animator.backgroundColor = UIColor.clear
        
        let refreshViewHeight = animator.refreshViewHeight()
        var vframe = animator.frame
        vframe.size.width = self.frame.size.width
        vframe.size.height = refreshViewHeight
        animator.frame = vframe
        
        self.addPullToRefreshWithAction(action, withAnimator: animator)
    }
}
