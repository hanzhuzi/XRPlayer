//
//  XRActivityInditor.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/25.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

class XRActivityInditor: UIView {

    private lazy var activityInditor: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var isAnimating: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.userInteractionEnabled = false
        self.layer.cornerRadius = 10.0
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        activityInditor.center = CGPointMake(self.frame.width * 0.5, self.frame.height * 0.5)
        isAnimating = activityInditor.isAnimating()
        self.addSubview(activityInditor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        activityInditor.center = CGPointMake(self.frame.width * 0.5, self.frame.height * 0.5)
    }
    
    func startAnimation() -> Void {
        if !activityInditor.isAnimating() {
            activityInditor.startAnimating()
            self.hidden = false
            isAnimating = activityInditor.isAnimating()
        }
    }
    
    func stopAnimation() -> Void {
        if activityInditor.isAnimating() {
            activityInditor.stopAnimating()
            self.hidden = true
            isAnimating = activityInditor.isAnimating()
        }
    }
}

