//
//  XRActivityInditor.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/25.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  @brief  视频加载activityIndicator
 *
 *  @by     黯丶野火
 */

import UIKit

class XRActivityInditor: UIView {
    
    var dgActivityView: DGActivityIndicatorView!
    var isAnimating: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = false
        dgActivityView = DGActivityIndicatorView(type: .ballSpinFadeLoader, tintColor: UIColor.white, size: self.frame.width)
        dgActivityView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.addSubview(dgActivityView)
        dgActivityView.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dgActivityView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    func startAnimation() -> Void {
        if !dgActivityView.animating {
            dgActivityView.startAnimating()
            self.isHidden = false
            isAnimating = dgActivityView.animating
        }
    }
    
    func stopAnimation() -> Void {
        if dgActivityView.animating {
            dgActivityView.stopAnimating()
            self.isHidden = true
            isAnimating = dgActivityView.animating
        }
    }
}

