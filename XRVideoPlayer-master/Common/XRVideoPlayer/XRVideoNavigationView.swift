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

    lazy var backButton: UIButton = UIButton(type: .custom)
    lazy var titleLabel: UILabel = UILabel()
    lazy var moreButton: UIButton = UIButton(type: .custom)
    var backButtonClosure: (() -> ())?
    var moreButtonClosure: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backButton.frame = CGRect(x: itemToLeft, y: statusBarHeight + (self.frame.height - statusBarHeight - navigationItemButtonWH) * 0.5, width: navigationItemButtonWH, height: navigationItemButtonWH)
        backButton.setImage(UIImage(named: "back"), for: UIControlState())
        backButton.addTarget(self, action: #selector(self.backButtonAction), for: .touchUpInside)
        self.addSubview(backButton)
        
        titleLabel.frame = CGRect(x: backButton.frame.maxX + itemToLeft, y: statusBarHeight + (frame.height  - statusBarHeight - navigationItemButtonWH) * 0.5, width: frame.width - (backButton.frame.maxX + itemToLeft) * 2.0, height: navigationItemButtonWH)
        titleLabel.font = UIFont.systemFont(ofSize: 15.0)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.text = "电视剧《隋唐演义》第一集"
        self.addSubview(titleLabel)
        
        moreButton.frame = CGRect(x: frame.maxX - navigationItemButtonWH - itemToLeft, y: statusBarHeight + (frame.height  - statusBarHeight - navigationItemButtonWH) * 0.5, width: navigationItemButtonWH, height: navigationItemButtonWH)
        moreButton.setImage(UIImage(named: "more"), for: UIControlState())
        moreButton.addTarget(self, action: #selector(self.moreButtonAction), for: .touchUpInside)
        self.addSubview(moreButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backButton.frame = CGRect(x: 8.0, y: 20.0 + (self.frame.height - 20.0 - navigationItemButtonWH) * 0.5, width: navigationItemButtonWH, height: navigationItemButtonWH)
        titleLabel.frame = CGRect(x: backButton.frame.maxX + 10.0, y: 20.0 + (frame.height  - 20.0 - navigationItemButtonWH) * 0.5, width: frame.width - (backButton.frame.maxX + 10.0) * 2.0, height: navigationItemButtonWH)
        moreButton.frame = CGRect(x: frame.maxX - navigationItemButtonWH - 8.0, y: 20.0 + (frame.height  - 20.0 - navigationItemButtonWH) * 0.5, width: navigationItemButtonWH, height: navigationItemButtonWH)
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


