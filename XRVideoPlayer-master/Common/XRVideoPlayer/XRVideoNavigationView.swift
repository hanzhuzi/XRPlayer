//
//  XRVideoNavigationView.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/29.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  @brief  视频播放器导航View
 *  
 *  @by     黯丶野火
 */

import UIKit

private let navigationItemButtonWH: CGFloat = 32.0
private let statusBarHeight: CGFloat = 20.0
private let itemToLeft: CGFloat = 10.0

class XRVideoNavigationView: UIView {

    lazy var backButton: UIButton = UIButton(type: .Custom)
    lazy var titleLabel: UILabel = UILabel()
    lazy var moreButton: UIButton = UIButton(type: .Custom)
    var backButtonClosure: (() -> ())?
    var moreButtonClosure: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backButton.frame = CGRectMake(itemToLeft, statusBarHeight + (self.frame.height - statusBarHeight - navigationItemButtonWH) * 0.5, navigationItemButtonWH, navigationItemButtonWH)
        backButton.setImage(UIImage(named: "back"), forState: .Normal)
        backButton.addTarget(self, action: #selector(self.backButtonAction), forControlEvents: .TouchUpInside)
        self.addSubview(backButton)
        
        titleLabel.frame = CGRectMake(CGRectGetMaxX(backButton.frame) + itemToLeft, statusBarHeight + (frame.height  - statusBarHeight - navigationItemButtonWH) * 0.5, frame.width - (CGRectGetMaxX(backButton.frame) + itemToLeft) * 2.0, navigationItemButtonWH)
        titleLabel.font = UIFont.systemFontOfSize(15.0)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.text = "电视剧《隋唐演义》第一集"
        self.addSubview(titleLabel)
        
        moreButton.frame = CGRectMake(CGRectGetMaxX(frame) - navigationItemButtonWH - itemToLeft, statusBarHeight + (frame.height  - statusBarHeight - navigationItemButtonWH) * 0.5, navigationItemButtonWH, navigationItemButtonWH)
        moreButton.setImage(UIImage(named: "more"), forState: .Normal)
        moreButton.addTarget(self, action: #selector(self.moreButtonAction), forControlEvents: .TouchUpInside)
        self.addSubview(moreButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backButton.frame = CGRectMake(8.0, 20.0 + (self.frame.height - 20.0 - navigationItemButtonWH) * 0.5, navigationItemButtonWH, navigationItemButtonWH)
        titleLabel.frame = CGRectMake(CGRectGetMaxX(backButton.frame) + 10.0, 20.0 + (frame.height  - 20.0 - navigationItemButtonWH) * 0.5, frame.width - (CGRectGetMaxX(backButton.frame) + 10.0) * 2.0, navigationItemButtonWH)
        moreButton.frame = CGRectMake(CGRectGetMaxX(frame) - navigationItemButtonWH - 8.0, 20.0 + (frame.height  - 20.0 - navigationItemButtonWH) * 0.5, navigationItemButtonWH, navigationItemButtonWH)
    }
    
    func backButtonAction() {
        if let closure = backButtonClosure {
            closure()
        }
    }
    
    func moreButtonAction() {
        if let closure = moreButtonClosure {
            closure()
        }
    }
}


