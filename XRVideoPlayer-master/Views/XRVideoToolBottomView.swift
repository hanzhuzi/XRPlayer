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
    lazy var controlSlider: UISlider = UISlider()
    lazy var rotateButton: UIButton = UIButton(type: .Custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        playButton.frame = CGRectMake(15, (self.frame.height - 25.0) * 0.5, 25, 25)
        playButton.backgroundColor = UIColor.whiteColor()
        self.addSubview(playButton)
        
        startTimeLbl.frame = CGRectMake(CGRectGetMaxX(playButton.frame) + 10.0, 0.0, 30.0, self.frame.height)
        startTimeLbl.textColor = UIColor.whiteColor()
        startTimeLbl.textAlignment = .Right
        startTimeLbl.font = UIFont.systemFontOfSize(10.0)
        startTimeLbl.text = "00:00"
        self.addSubview(startTimeLbl)
        
        rotateButton.frame = CGRectMake(CGRectGetMaxX(self.frame) - 15.0 - 25.0, (self.frame.height - 25.0) * 0.5, 25, 25)
        rotateButton.backgroundColor = UIColor.whiteColor()
        self.addSubview(rotateButton)
        
        endTimeLbl.frame = CGRectMake(CGRectGetMinX(rotateButton.frame) - 40.0, 0.0, 30.0, self.frame.height)
        endTimeLbl.textColor = UIColor.whiteColor()
        endTimeLbl.textAlignment = .Left
        endTimeLbl.font = UIFont.systemFontOfSize(10.0)
        endTimeLbl.text = "15:00"
        self.addSubview(endTimeLbl)
        
        progressBar.frame = CGRectMake(CGRectGetMaxX(startTimeLbl.frame) + 8.0, bounds.height * 0.5 - 1.0, CGRectGetMinX(endTimeLbl.frame) - 10.0 - CGRectGetMaxX(startTimeLbl.frame) - 8.0, 2.0)
        progressBar.progressViewStyle = .Default
        progressBar.progressTintColor = UIColor.redColor()
        progressBar.trackTintColor = UIColor.lightGrayColor()
        self.addSubview(progressBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func seccondConvertTime(seccond: Float) -> Float {
        
        return 0
    }
    
    func setStartTimeWithSecconds(seccond: Float) -> Void {
        
        
    }
    
    func setEndTimeWithSecconds(seccond: Float) -> Void {
        
        
    }
    
    func setProgress(progress: Float) -> Void {
        
        progressBar.setProgress(progress, animated: true)
    }
    
}
