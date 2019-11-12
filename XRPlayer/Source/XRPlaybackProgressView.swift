//
//  XRPlaybackProgressView.swift
//  QukeMechanic
//
//  Created by 徐冉 on 2019/8/22.
//  Copyright © 2019 QK. All rights reserved.
//

import UIKit

class XRPlaybackProgressView: UIView {

    var currentTime: TimeInterval = 0
    var totalTime: TimeInterval = 0
    
    var progress: Double = 0.0
    
    lazy var playbackImageView: UIImageView = UIImageView(frame: CGRect.zero)
    lazy var timeLbl: UILabel = UILabel(frame: CGRect.zero)
    lazy var progressBar: XRProgressView = XRProgressView(frame: CGRect.zero, progress: 0.0)
    
    private var isShowing: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 3.0
        self.alpha = 0
        
        self.addSubview(self.timeLbl)
        self.timeLbl.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview().offset(7)
            make.height.greaterThanOrEqualTo(10)
        }
        
        self.timeLbl.textColor = UIColor.white
        self.timeLbl.font = UIFont.systemFont(ofSize: 14)
        self.timeLbl.textAlignment = .center
        self.timeLbl.text = "00:00 / 00:00"
        
        self.addSubview(playbackImageView)
        playbackImageView.snp.makeConstraints { (make) in
            make.width.greaterThanOrEqualTo(10)
            make.height.greaterThanOrEqualTo(10)
            make.centerX.equalToSuperview().offset(0)
            make.bottom.equalTo(self.timeLbl.snp.top).offset(-5)
        }
        
        self.playbackImageView.image = xrplayer_imageForBundleResource(imageName: "icon_player_playback_forword", bundleClass: self.classForCoder)
        
        progressBar.backgroundColor = xrplayer_UIColorFromRGB(hexRGB: 0x898989)
        progressBar.trackColor = xrplayer_UIColorFromRGB(hexRGB: 0xffffff)
        progressBar.layer.masksToBounds = true
        progressBar.layer.cornerRadius = 1.0
        self.addSubview(progressBar)
        progressBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.height.equalTo(2.0)
            make.top.equalTo(self.timeLbl.snp.bottom).offset(7)
        }
        
    }
    
    private func seccondConvertTime(_ seccond: Double) -> String {
        
        guard !seccond.isNaN else { return "00:00" }
        
        var secconds = Int(seccond)
        
        let timeString: NSMutableString = NSMutableString()
        
        if secconds >= 3600 {
            let hours = secconds / 3600
            timeString.appendFormat("%02d:", hours)
            secconds = secconds % 3600
        }
        
        let mins = secconds / 60
        timeString.appendFormat("%02d:", mins)
        secconds = secconds % 60
        
        timeString.appendFormat("%02d", secconds)
        
        return timeString as String
    }
    
    func setPlaybackProgressWithCurrentTime(currentTime: TimeInterval, totalTime: TimeInterval, progress: Float, isPlaybackForword: Bool) {
        
        let timeText = self.seccondConvertTime(currentTime) + " / " + self.seccondConvertTime(totalTime)
        
        self.timeLbl.text = timeText
        
        self.playbackImageView.image = isPlaybackForword ? xrplayer_imageForBundleResource(imageName: "icon_player_playback_forword", bundleClass: self.classForCoder) : xrplayer_imageForBundleResource(imageName: "icon_player_playback_backword", bundleClass: self.classForCoder)
        self.progressBar.progress = CGFloat(progress)
    }
    
    func show() -> Void {
        
        if !isShowing {
            isShowing = true
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                if let weakSelf = self {
                    weakSelf.alpha = 1.0
                }
            }, completion: { [weak self](_) in
                if let weakSelf = self {
                    weakSelf.isShowing = true
                }
            })
        }
    }
    
    func hide() -> Void {
        
        if isShowing {
            isShowing = false
            UIView.animate(withDuration: 0.28, animations: { [weak self] in
                if let weakSelf = self {
                    weakSelf.alpha = 0.0
                }
            }, completion: { [weak self](_) in
                if let weakSelf = self {
                    weakSelf.isShowing = false
                }
            })
        }
    }
    
}
