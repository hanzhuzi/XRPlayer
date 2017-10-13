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

private let navigationItemButtonWH: CGFloat = 44.0
private let statusBarHeight: CGFloat = 20.0
private let itemToLeft: CGFloat = 12.0

class XRVideoNavigationView: UIView {
    
    lazy var backButton: UIButton = UIButton(type: .custom)
    lazy var titleLabel: UILabel = UILabel()
    lazy var downloadButton: UIButton = UIButton(type: .custom)
    var backButtonClosure: (() -> ())?
    var downloadButtonClosure: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backButton.frame = CGRect(x: itemToLeft, y: statusBarHeight + (self.frame.height - statusBarHeight - navigationItemButtonWH) * 0.5, width: navigationItemButtonWH, height: navigationItemButtonWH)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(self.backButtonAction), for: .touchUpInside)
        self.addSubview(backButton)
        
        titleLabel.frame = CGRect(x: backButton.frame.maxX + itemToLeft, y: statusBarHeight + (frame.height  - statusBarHeight - navigationItemButtonWH) * 0.5, width: frame.width - (backButton.frame.maxX + itemToLeft) * 2.0, height: navigationItemButtonWH)
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        
        downloadButton.frame = CGRect(x: self.bounds.maxX - navigationItemButtonWH - itemToLeft, y: statusBarHeight + (frame.height  - statusBarHeight - navigationItemButtonWH) * 0.5, width: navigationItemButtonWH, height: navigationItemButtonWH)
        downloadButton.setImage(UIImage(named: "downloading"), for: .normal)
        downloadButton.addTarget(self, action: #selector(self.moreButtonAction), for: .touchUpInside)
        self.addSubview(downloadButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backButton.frame = CGRect(x: 8.0, y: 20.0 + (self.frame.height - 20.0 - navigationItemButtonWH) * 0.5, width: navigationItemButtonWH, height: navigationItemButtonWH)
        titleLabel.frame = CGRect(x: backButton.frame.maxX + 10.0, y: 20.0 + (frame.height  - 20.0 - navigationItemButtonWH) * 0.5, width: frame.width - (backButton.frame.maxX + 10.0) * 2.0, height: navigationItemButtonWH)
        downloadButton.frame = CGRect(x: bounds.maxX - navigationItemButtonWH - 8.0, y: 20.0 + (frame.height  - 20.0 - navigationItemButtonWH) * 0.5, width: navigationItemButtonWH, height: navigationItemButtonWH)
    }
    
    func backButtonAction() {
        if let closure = backButtonClosure {
            closure()
        }
    }
    
    func moreButtonAction() {
        if let closure = downloadButtonClosure {
            closure()
        }
    }
}


