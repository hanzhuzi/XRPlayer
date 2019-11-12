//
//  XRVideoToolBottomView.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/23.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  @brief  视频播放底部工具条
 *
 *  @by     黯丶野火
 **/

import UIKit

class XRSlider: UISlider {
    
    open var sliderLineWidth: CGFloat = 1.0
    open var isAllowDraging: Bool = true {
        
        didSet {
            if isAllowDraging == false {
                self.value = 0.0
            }
        }
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.size.height = sliderLineWidth
        rect.origin.y = (frame.height - rect.height) * 0.5
        return rect
    }
    
}

class XRPlayerToolBarView: UIView {
    
    lazy var playButton: UIButton = UIButton(type: .custom)
    lazy var startTimeLbl: UILabel = UILabel()
    lazy var endTimeLbl: UILabel = UILabel()
    lazy var progressBar: XRProgressView = XRProgressView(frame: CGRect.zero, progress: 0.0)
    lazy var slider: XRSlider = {
        
        return XRSlider()
    }()
    lazy var rotateButton: UIButton = UIButton(type: .custom)
    
    /// 是否可以拖动滑块
    var isAllowDragingSlider: Bool = false {
        didSet {
            slider.isUserInteractionEnabled = isAllowDragingSlider
            slider.isAllowDraging = isAllowDragingSlider
        }
    }
    
    var playButtonClickClosure: (() -> ())?
    var rotationOrientationClosure: (() -> ())?
    var sliderValueChangedClosure: ((_ value: Float, _ events: UIControl.Event) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backImgView = UIImageView(frame: self.bounds)
        self.addSubview(backImgView)
        backImgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        if let shadowImg = xrplayer_imageForBundleResource(imageName: "icon_player_bottom_shadow", bundleClass: self.classForCoder) {
            let stretchImg = shadowImg.stretchableImage(withLeftCapWidth: Int(shadowImg.size.width * 0.5), topCapHeight: Int(shadowImg.size.height * 0.6))
            backImgView.image = stretchImg
        }
        else {
            backImgView.image = xrplayer_imageForBundleResource(imageName: "icon_player_bottom_shadow", bundleClass: self.classForCoder)
        }
        
        playButton.frame = CGRect(x: 15, y: (self.frame.height - 30.0) * 0.5, width: 30, height: 30)
        playButton.setImage(xrplayer_imageForBundleResource(imageName: "icon_player_play", bundleClass: self.classForCoder), for: UIControl.State.normal)
        playButton.setImage(xrplayer_imageForBundleResource(imageName: "icon_player_pause", bundleClass: self.classForCoder), for: .selected)
        playButton.addTarget(self, action: #selector(self.playButtonClickAction), for: .touchUpInside)
        self.addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(44)
        }
        
        startTimeLbl.frame = CGRect(x: playButton.frame.maxX + 3.0, y: 0.0, width: 58.0, height: self.frame.height)
        startTimeLbl.textColor = UIColor.white
        startTimeLbl.textAlignment = .center
        startTimeLbl.font = UIFont.systemFont(ofSize: 12.0)
        startTimeLbl.text = "00:00"
        self.addSubview(startTimeLbl)
        startTimeLbl.snp.makeConstraints { (make) in
            make.left.equalTo(self.playButton.snp.right).offset(0)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(58)
        }
        
        rotateButton.setImage(xrplayer_imageForBundleResource(imageName: "icon_player_enterfull", bundleClass: self.classForCoder), for: UIControl.State.normal)
        rotateButton.setImage(xrplayer_imageForBundleResource(imageName: "icon_player_quitfull", bundleClass: self.classForCoder), for: .selected)
        rotateButton.addTarget(self, action: #selector(self.rotateOrientationAction), for: .touchUpInside)
        self.addSubview(rotateButton)
        rotateButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(0)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(44)
        }
        
        endTimeLbl.frame = CGRect(x: rotateButton.frame.minX - 61.0, y: 0.0, width: 58.0, height: self.frame.height)
        endTimeLbl.textColor = UIColor.white
        endTimeLbl.textAlignment = .center
        endTimeLbl.font = UIFont.systemFont(ofSize: 12.0)
        endTimeLbl.text = "00:00"
        self.addSubview(endTimeLbl)
        endTimeLbl.snp.makeConstraints { (make) in
            make.right.equalTo(self.rotateButton.snp.left).offset(0)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(58)
        }
        
        progressBar.backgroundColor = xrplayer_UIColorFromRGB(hexRGB: 0x898989)
        progressBar.trackColor = xrplayer_UIColorFromRGB(hexRGB: 0xcecece)
        progressBar.layer.masksToBounds = true
        progressBar.layer.cornerRadius = 1.0
        self.addSubview(progressBar)
        progressBar.snp.makeConstraints { (make) in
            make.left.equalTo(self.startTimeLbl.snp.right).offset(8)
            make.right.equalTo(self.endTimeLbl.snp.left).offset(-8)
            make.height.equalTo(1.5)
            make.centerY.equalToSuperview().offset(0)
        }
        
        slider.frame = CGRect(x: startTimeLbl.frame.maxX + 5.0, y: 0.0, width: endTimeLbl.frame.minX - 10.0 - startTimeLbl.frame.maxX - 2.0, height: bounds.height)
        slider.backgroundColor = UIColor.clear
        slider.maximumTrackTintColor = UIColor.clear
        slider.minimumTrackTintColor = UIColor.white
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = 0.0
        slider.sliderLineWidth = 1.5
        slider.isContinuous = true
        
        slider.setThumbImage(xrplayer_imageForBundleResource(imageName: "icon_player_progress_point", bundleClass: self.classForCoder), for: UIControl.State.normal)
        slider.setThumbImage(xrplayer_imageForBundleResource(imageName: "icon_player_progress_point", bundleClass: self.classForCoder), for: UIControl.State.highlighted)
        slider.setThumbImage(xrplayer_imageForBundleResource(imageName: "icon_player_progress_point", bundleClass: self.classForCoder), for: UIControl.State.disabled)
        
        slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(self.sliderTouchDown(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(self.sliderTouchUp(_:)), for: .touchUpInside)
        self.addSubview(slider)
        
        slider.snp.makeConstraints { (make) in
            make.left.equalTo(self.startTimeLbl.snp.right).offset(5)
            make.right.equalTo(self.endTimeLbl.snp.left).offset(-5)
            make.top.bottom.equalToSuperview()
        }
        
        self.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func layoutToolBarWithISFullScreenPlay(isFullScreen: Bool) {
    
        if isFullScreen {
            playButton.snp.updateConstraints { (make) in
                if xrPlayer_iSiPhoneXSerries() {
                    make.left.equalToSuperview().offset(26)
                }
                else {
                    make.left.equalToSuperview().offset(10)
                }
            }
            
            rotateButton.snp.updateConstraints { (make) in
                if xrPlayer_iSiPhoneXSerries() {
                    make.right.equalToSuperview().offset(-26)
                }
                else {
                    make.right.equalToSuperview().offset(-10)
                }
            }
        }
        else {
            playButton.snp.updateConstraints { (make) in
                make.left.equalToSuperview().offset(0)
            }
            
            rotateButton.snp.updateConstraints { (make) in
                make.right.equalToSuperview().offset(0)
            }
        }
    }
    
    @objc func sliderValueChanged(_ slider: XRSlider) -> Void {
        
        if !slider.isAllowDraging {
            slider.value = 0.0
            return
        }
        if let closure = sliderValueChangedClosure {
            closure(slider.value, .valueChanged)
        }
    }
    
    @objc func sliderTouchDown(_ slider: XRSlider) {
        
        if !slider.isAllowDraging {
            slider.value = 0.0
            return
        }
        if let closure = sliderValueChangedClosure {
            closure(slider.value, .touchDown)
        }
    }
    
    @objc func sliderTouchUp(_ slider: XRSlider) {
        
        if !slider.isAllowDraging {
            slider.value = 0.0
            return
        }
        if let closure = sliderValueChangedClosure {
            closure(slider.value, .touchUpInside)
        }
    }
    
    @objc func rotateOrientationAction() -> Void {
        
        if let closure = rotationOrientationClosure {
            closure()
        }
    }
    
    @objc func playButtonClickAction() -> Void {
        
        if let closure = playButtonClickClosure {
            closure()
        }
    }
    
    func setSliderProgress(_ progress: Double) -> Void {
        
        var precent = progress
        if precent > 1.0 {
            precent = 1.0
        }else if precent < 0.0 {
            precent = 0.0
        }
        
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                weakSelf.slider.setValue(Float(progress), animated: true)
            }
        }
    }
    
    func setPlayButtonState(_ isPlaying: Bool) -> Void {
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                weakSelf.playButton.isSelected = isPlaying
            }
        }
    }
    
    func setPlayButtonIsHidden(isHiddenButton: Bool) {
        
        if isHiddenButton {
            playButton.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(0)
                make.top.bottom.equalToSuperview()
                make.width.equalTo(5)
            }
            
            playButton.isHidden = true
        }
        else {
            playButton.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(0)
                make.top.bottom.equalToSuperview()
                make.width.equalTo(44)
            }
            
            playButton.isHidden = false
        }
        
        self.setNeedsLayout()
    }
    
    func setRotateButtonStatus(_ isFull: Bool) -> Void {
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                weakSelf.rotateButton.isSelected = isFull
            }
        }
    }
    
    func seccondConvertTime(_ seccond: Double) -> String {
        
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
    
    func setStartTimeWithSecconds(_ seccond: Double) -> Void {
        
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                let timeStr = weakSelf.seccondConvertTime(seccond.isNaN ? 0 : seccond)
                weakSelf.startTimeLbl.text = timeStr
            }
        }
    }
    
    func setEndTimeWithSecconds(_ seccond: Double) -> Void {
        
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                let timeStr = weakSelf.seccondConvertTime(seccond.isNaN ? 0 : seccond)
                weakSelf.endTimeLbl.text = timeStr
                if seccond.isNaN || seccond == 0 {
                    weakSelf.isAllowDragingSlider = false
                }
                else {
                    weakSelf.isAllowDragingSlider = true
                }
            }
        }
    }
    
    func setProgress(_ progress: Float) -> Void {
        
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                if !progress.isNaN {
                    weakSelf.progressBar.progress = CGFloat(progress)
                }
                else {
                    weakSelf.progressBar.progress = CGFloat(0.0)
                }
            }
        }
    }
    
}
