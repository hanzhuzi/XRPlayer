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

class XPlayerNavigationView: UIView {
    
    lazy var backButton: UIButton = UIButton(type: .custom)
    lazy var titleLabel: UILabel = UILabel()
    lazy var rightButton: UIButton = UIButton(type: .custom)
    
    var backButtonClosure: (() -> ())?
    var rightButtonClosure: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backImgView = UIImageView(frame: self.bounds)
        self.addSubview(backImgView)
        backImgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        if let shadowImg = xrplayer_imageForBundleResource(imageName: "icon_player_top_shadow", bundleClass: self.classForCoder) {
            let stretchImg = shadowImg.stretchableImage(withLeftCapWidth: Int(shadowImg.size.width * 0.5), topCapHeight: Int(shadowImg.size.height * 0.3))
            backImgView.image = stretchImg
        }
        else {
            backImgView.image = xrplayer_imageForBundleResource(imageName: "icon_player_top_shadow", bundleClass: self.classForCoder)
        }
        
        backButton.setImage(xrplayer_imageForBundleResource(imageName: "icon_player_back", bundleClass: self.classForCoder), for: .normal)
        backButton.addTarget(self, action: #selector(self.backButtonAction), for: .touchUpInside)
        self.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            if xrPlayer_iSiPhoneXSerries() {
                make.top.equalToSuperview().offset(40)
            }
            else {
                make.top.equalToSuperview().offset(20)
            }
            make.width.equalTo(50)
            make.height.equalTo(44)
        }
        
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .left
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.backButton.snp.right).offset(0)
            make.right.equalToSuperview().offset(-30)
            make.height.greaterThanOrEqualTo(10)
            make.centerY.equalTo(self.backButton).offset(0)
        }
        
        self.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func layoutNavigationBarWithISFullScreenPlay(isFullScreen: Bool) {
        
        if isFullScreen {
            backButton.snp.updateConstraints { (make) in
                
                if xrPlayer_iSiPhoneXSerries() {
                    make.left.equalToSuperview().offset(25)
                    make.top.equalToSuperview().offset(20)
                }
                else {
                    make.left.equalToSuperview().offset(10)
                    make.top.equalToSuperview().offset(10)
                }
            }
        }
        else {
            backButton.snp.updateConstraints { (make) in
                make.left.equalToSuperview().offset(0)
                if xrPlayer_iSiPhoneXSerries() {
                    make.top.equalToSuperview().offset(44)
                }
                else {
                    make.top.equalToSuperview().offset(20)
                }
            }
        }
    }
    
    @objc func backButtonAction() {
        
        if let closure = backButtonClosure {
            closure()
        }
    }
    
    @objc func moreButtonAction() {
        
        if let closure = rightButtonClosure {
            closure()
        }
    }
}


