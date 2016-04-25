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
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        activityInditor.center = self.center
        activityInditor.frame = self.bounds
        activityInditor.hidden = false
        isAnimating = activityInditor.isAnimating()
        self.addSubview(activityInditor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        activityInditor.center = center
    }
    
    func startAnimation() -> Void {
        activityInditor.startAnimating()
        isAnimating = activityInditor.isAnimating()
    }
    
    func stopAnimation() -> Void {
        activityInditor.stopAnimating()
        isAnimating = activityInditor.isAnimating()
    }
}
