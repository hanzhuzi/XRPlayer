//
//  XRVideoToolBottomView.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/23.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  视频播放底部工具条
 **/

import UIKit

class XRVideoToolBottomView: UIView {
    
    lazy var playButton: UIButton = UIButton(type: .Custom)
    lazy var startTimeLbl: UILabel = UILabel()
    lazy var endTimeLbl: UILabel = UILabel()
    lazy var progressBar: UIProgressView = UIProgressView()
    lazy var slider: UISlider = {
        
        return UISlider()
    }()
    lazy var controlSlider: UISlider = UISlider()
    lazy var rotateButton: UIButton = UIButton(type: .Custom)
    var playButtonClickClosure: (() -> ())?
    var rotationOrientationClosure: (() -> ())?
    var sliderValueChangedClosure: ((value: Float) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        playButton.frame = CGRectMake(15, (self.frame.height - 30.0) * 0.5, 30, 30)
        playButton.setImage(UIImage(named: "play"), forState: .Normal)
        playButton.setImage(UIImage(named: "pause"), forState: .Selected)
        playButton.addTarget(self, action: #selector(self.playButtonClick), forControlEvents: .TouchUpInside)
        self.addSubview(playButton)
        
        startTimeLbl.frame = CGRectMake(CGRectGetMaxX(playButton.frame) + 5.0, 0.0, 50.0, self.frame.height)
        startTimeLbl.textColor = UIColor.whiteColor()
        startTimeLbl.textAlignment = .Right
        startTimeLbl.font = UIFont.systemFontOfSize(10.0)
        startTimeLbl.text = "00:00:00"
        self.addSubview(startTimeLbl)
        
        rotateButton.frame = CGRectMake(CGRectGetMaxX(self.frame) - 10.0 - 30.0, (self.frame.height - 30.0) * 0.5, 30, 30)
        rotateButton.setImage(UIImage(named: "tofull"), forState: .Normal)
        rotateButton.setImage(UIImage(named: "closefull"), forState: .Selected)
        rotateButton.addTarget(self, action: #selector(self.rotateOrientation), forControlEvents: .TouchUpInside)
        self.addSubview(rotateButton)
        
        endTimeLbl.frame = CGRectMake(CGRectGetMinX(rotateButton.frame) - 50.0, 0.0, 50.0, self.frame.height)
        endTimeLbl.textColor = UIColor.whiteColor()
        endTimeLbl.textAlignment = .Left
        endTimeLbl.font = UIFont.systemFontOfSize(10.0)
        endTimeLbl.text = "00:00:00"
        self.addSubview(endTimeLbl)
        
        progressBar.frame = CGRectMake(CGRectGetMaxX(startTimeLbl.frame) + 8.0, bounds.height * 0.5 - 1.0, CGRectGetMinX(endTimeLbl.frame) - 10.0 - CGRectGetMaxX(startTimeLbl.frame) - 8.0, 2.0)
        progressBar.progressViewStyle = .Default
        progressBar.progressTintColor = UIColor.darkGrayColor()
        progressBar.trackTintColor = UIColor.lightGrayColor()
        self.addSubview(progressBar)
        
        slider.frame = CGRectMake(CGRectGetMaxX(startTimeLbl.frame) + 5.0, (bounds.height - 25.0) * 0.5, CGRectGetMinX(endTimeLbl.frame) - 10.0 - CGRectGetMaxX(startTimeLbl.frame) - 5.0, 25.0)
        slider.backgroundColor = UIColor.clearColor()
        slider.maximumTrackTintColor = UIColor.clearColor()
        slider.setThumbImage(UIImage(named: "player-progress-point-h"), forState: .Normal)
        slider.minimumTrackTintColor = UIColor.redColor()
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
        self.addSubview(slider)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playButton.frame = CGRectMake(15, (self.frame.height - 30.0) * 0.5, 30, 30)
        
        startTimeLbl.frame = CGRectMake(CGRectGetMaxX(playButton.frame) + 5.0, 0.0, 50.0, self.frame.height)
        
        rotateButton.frame = CGRectMake(CGRectGetMaxX(self.frame) - 10.0 - 30.0, (self.frame.height - 30.0) * 0.5, 30, 30)
        
        endTimeLbl.frame = CGRectMake(CGRectGetMinX(rotateButton.frame) - 50.0, 0.0, 50.0, self.frame.height)
        
        progressBar.frame = CGRectMake(CGRectGetMaxX(startTimeLbl.frame) + 8.0, bounds.height * 0.5 - 1.0, CGRectGetMinX(endTimeLbl.frame) - 10.0 - CGRectGetMaxX(startTimeLbl.frame) - 8.0, 2.0)
        slider.frame = CGRectMake(CGRectGetMaxX(startTimeLbl.frame) + 5.0, (bounds.height - 25.0) * 0.5, CGRectGetMinX(endTimeLbl.frame) - 10.0 - CGRectGetMaxX(startTimeLbl.frame) - 5.0, 25.0)
    }
    
    func sliderValueChanged(slider: UISlider) -> Void {
        
        if let closure = sliderValueChangedClosure {
            closure(value: slider.value)
        }
    }
    
    func rotateOrientation() -> Void {
        
        if let closure = rotationOrientationClosure {
            closure()
        }
    }
    
    func playButtonClick() -> Void {
        
        if let closure = playButtonClickClosure {
            closure()
        }
    }
    
    func setSliderProgress(progress: Double) -> Void {
        
        var precent = progress
        if precent > 1.0 {
            precent = 1.0
        }else if precent < 0.0 {
            precent = 0.0
        }
        
        slider.setValue(Float(progress), animated: true)
    }
    
    func setPlayButtonState(isPlaying: Bool) -> Void {
        playButton.selected = isPlaying
    }
    
    func seccondConvertTime(seccond: Double) -> String {
        
        let secconds = Int(seccond) % 60
        let minutes  = Int(seccond) / 60
        let hours    = Int(seccond) / 3600
        
        let timeString = NSString.localizedStringWithFormat("%02d:%02d:%02d", hours, minutes, secconds)
        return timeString as String
    }
    
    func setStartTimeWithSecconds(seccond: Double) -> Void {
        
        let timeStr = seccondConvertTime(seccond)
        startTimeLbl.text = timeStr
    }
    
    func setEndTimeWithSecconds(seccond: Double) -> Void {
        
        let timeStr = seccondConvertTime(seccond)
        endTimeLbl.text = timeStr
    }
    
    func setProgress(progress: Float) -> Void {
        
        progressBar.setProgress(progress, animated: true)
    }
    
}
