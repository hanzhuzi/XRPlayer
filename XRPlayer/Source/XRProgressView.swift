//
//  XRProgressView.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/11/14.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

class XRProgressView: UIView {
    
    open var trackColor: UIColor = UIColor.lightGray {
        didSet {
            overlayLayer.backgroundColor = trackColor.cgColor
        }
    }
    
    open var progress: CGFloat = 0.0 {
        
        didSet {
            if progress > 1.0 {
                progress = 1.0
            }
            else if progress < 0.0 {
                progress = 0.0
            }
            else if progress.isNaN { // not use == nan beacuse it's always is false should use isNaN
                progress = 0.0
            }
            
            overlayLayer.frame = CGRect(x: 0, y: 0, width: progress * self.frame.width, height: self.frame.height)
        }
    }
    fileprivate var overlayLayer: CAShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        overlayLayer.frame = CGRect(x: 0, y: 0, width: 0, height: frame.height)
        overlayLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        overlayLayer.backgroundColor = trackColor.cgColor
        self.layer.addSublayer(overlayLayer)
        
        self.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(frame: CGRect , progress: CGFloat) {
        self.init(frame: frame)
        
        self.progress = progress
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        overlayLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width * progress, height: frame.height)
    }
    
}
