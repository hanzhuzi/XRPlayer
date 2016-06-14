//
//  RegulationBrightness.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/23.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  @brief  仿支付宝付款页面呼吸灯效果
 *  
 *  @by     黯丶野火
 */

import UIKit

class RegulationBrightness: NSObject {
    
    var preBrightness: CGFloat = UIScreen.mainScreen().brightness
    var systemBrightness: CGFloat = 0
    var jumpBrightness: CGFloat = 0.8
    var timer: NSTimer?
    var isToHeigh = false
    
    private override init() {
        super.init()
    }
    
    private struct Inner {
        static var regulationBright: RegulationBrightness?
        static var onceToken: dispatch_once_t = 0
    }
    
    static func sharedBrightness() -> RegulationBrightness {
        
        dispatch_once(&Inner.onceToken) {
            if Inner.regulationBright == nil {
                Inner.regulationBright = RegulationBrightness()
            }
        }
        
        return Inner.regulationBright!
    }
    
    func startBrightTimer(isToHeigh: Bool) {
    
        if isToHeigh {
            systemBrightness = UIScreen.mainScreen().brightness
        }
        
        self.isToHeigh = isToHeigh
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(RegulationBrightness.regulationBrightnessToHeigh(_:)), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        }
    }
    
    func stopBrightTimer() {
        
        timer?.invalidate()
        timer = nil
    }
    
    func regulationBrightnessToHeigh(timer: NSTimer) {
        
        print("\(preBrightness), \(systemBrightness)")
        if isToHeigh {
            if preBrightness >= jumpBrightness {
                preBrightness = jumpBrightness
                stopBrightTimer()
            }else {
                preBrightness += 0.01
            }
        }else {
            if preBrightness <= systemBrightness {
                preBrightness = systemBrightness
                stopBrightTimer()
            }else {
                preBrightness -= 0.01
            }
        }
        
        UIScreen.mainScreen().brightness = preBrightness
    }
    
}
