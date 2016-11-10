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

class XRVideoToolBottomView: UIView {
    
    lazy var playButton: UIButton = UIButton(type: .custom)
    lazy var startTimeLbl: UILabel = UILabel()
    lazy var endTimeLbl: UILabel = UILabel()
    lazy var progressBar: UIProgressView = UIProgressView()
    lazy var slider: UISlider = {
        
        return UISlider()
    }()
    lazy var controlSlider: UISlider = UISlider()
    lazy var rotateButton: UIButton = UIButton(type: .custom)
    var playButtonClickClosure: (() -> ())?
    var rotationOrientationClosure: (() -> ())?
    var sliderValueChangedClosure: ((_ value: Float) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        playButton.frame = CGRect(x: 15, y: (self.frame.height - 30.0) * 0.5, width: 30, height: 30)
        playButton.setImage(UIImage(named: "play"), for: UIControlState())
        playButton.setImage(UIImage(named: "pause"), for: .selected)
        playButton.addTarget(self, action: #selector(self.playButtonClick), for: .touchUpInside)
        self.addSubview(playButton)
        
        startTimeLbl.frame = CGRect(x: playButton.frame.maxX + 5.0, y: 0.0, width: 50.0, height: self.frame.height)
        startTimeLbl.textColor = UIColor.white
        startTimeLbl.textAlignment = .right
        startTimeLbl.font = UIFont.systemFont(ofSize: 11.0)
        startTimeLbl.text = "00:00:00"
        self.addSubview(startTimeLbl)
        
        rotateButton.frame = CGRect(x: self.frame.maxX - 10.0 - 30.0, y: (self.frame.height - 30.0) * 0.5, width: 30, height: 30)
        rotateButton.setImage(UIImage(named: "tofull"), for: UIControlState())
        rotateButton.setImage(UIImage(named: "closefull"), for: .selected)
        rotateButton.addTarget(self, action: #selector(self.rotateOrientation), for: .touchUpInside)
        self.addSubview(rotateButton)
        
        endTimeLbl.frame = CGRect(x: rotateButton.frame.minX - 50.0, y: 0.0, width: 50.0, height: self.frame.height)
        endTimeLbl.textColor = UIColor.white
        endTimeLbl.textAlignment = .left
        endTimeLbl.font = UIFont.systemFont(ofSize: 11.0)
        endTimeLbl.text = "00:00:00"
        self.addSubview(endTimeLbl)
        
        progressBar.frame = CGRect(x: startTimeLbl.frame.maxX + 8.0, y: bounds.height * 0.5 - 1.0, width: endTimeLbl.frame.minX - 10.0 - startTimeLbl.frame.maxX - 8.0, height: 2.0)
        progressBar.progressViewStyle = .default
        progressBar.progressTintColor = UIColor.darkGray
        progressBar.trackTintColor = UIColor.lightGray
        self.addSubview(progressBar)
        
        slider.frame = CGRect(x: startTimeLbl.frame.maxX + 5.0, y: (bounds.height - 25.0) * 0.5, width: endTimeLbl.frame.minX - 10.0 - startTimeLbl.frame.maxX - 5.0, height: 25.0)
        slider.backgroundColor = UIColor.clear
        slider.maximumTrackTintColor = UIColor.clear
        slider.setThumbImage(UIImage(named: "player-progress-point-h"), for: UIControlState())
        slider.minimumTrackTintColor = UIColor.red
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
        self.addSubview(slider)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playButton.frame = CGRect(x: 15, y: (self.frame.height - 30.0) * 0.5, width: 30, height: 30)
        
        startTimeLbl.frame = CGRect(x: playButton.frame.maxX + 5.0, y: 0.0, width: 50.0, height: self.frame.height)
        
        rotateButton.frame = CGRect(x: self.frame.maxX - 10.0 - 30.0, y: (self.frame.height - 30.0) * 0.5, width: 30, height: 30)
        
        endTimeLbl.frame = CGRect(x: rotateButton.frame.minX - 50.0, y: 0.0, width: 50.0, height: self.frame.height)
        
        progressBar.frame = CGRect(x: startTimeLbl.frame.maxX + 8.0, y: bounds.height * 0.5 - 1.0, width: endTimeLbl.frame.minX - 10.0 - startTimeLbl.frame.maxX - 8.0, height: 2.0)
        slider.frame = CGRect(x: startTimeLbl.frame.maxX + 5.0, y: (bounds.height - 25.0) * 0.5, width: endTimeLbl.frame.minX - 10.0 - startTimeLbl.frame.maxX - 5.0, height: 25.0)
    }
    
    func sliderValueChanged(_ slider: UISlider) -> Void {
        
        if let closure = sliderValueChangedClosure {
            closure(slider.value)
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
    
    func setSliderProgress(_ progress: Double) -> Void {
        
        var precent = progress
        if precent > 1.0 {
            precent = 1.0
        }else if precent < 0.0 {
            precent = 0.0
        }
        
        slider.setValue(Float(progress), animated: true)
    }
    
    func setPlayButtonState(_ isPlaying: Bool) -> Void {
        playButton.isSelected = isPlaying
    }
    
    func setRotateButtonStatus(_ isFull: Bool) -> Void {
        rotateButton.isSelected = isFull
    }
    
    func seccondConvertTime(_ seccond: Double) -> String {
        
        guard !seccond.isNaN else { return "" }
        
        let secconds = Int(seccond) % 60
        let minutes  = Int(seccond) / 60
        let hours    = Int(seccond) / 3600
        let timeString = NSString.localizedStringWithFormat("%02d:%02d:%02d", hours, minutes, secconds)
        return timeString as String
    }
    
    func setStartTimeWithSecconds(_ seccond: Double) -> Void {
        
        let timeStr = seccondConvertTime(seccond)
        startTimeLbl.text = timeStr
    }
    
    func setEndTimeWithSecconds(_ seccond: Double) -> Void {
        
        let timeStr = seccondConvertTime(seccond)
        endTimeLbl.text = timeStr
    }
    
    func setProgress(_ progress: Float) -> Void {
        
        progressBar.setProgress(progress, animated: true)
    }
    
}
