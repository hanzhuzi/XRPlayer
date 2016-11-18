//
//  RegulationBrightness.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/23.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 * @brief  仿支付宝付款页面呼吸灯效果
 *  
 * @by     黯丶野火
 */

import UIKit

class RegulationBrightness: NSObject {
    
    fileprivate static var __once: () = {
            if Inner.regulationBright == nil {
                Inner.regulationBright = RegulationBrightness()
            }
        }()
    
    var preBrightness: CGFloat = UIScreen.main.brightness
    var systemBrightness: CGFloat = 0
    var jumpBrightness: CGFloat = 0.8
    var timer: Timer?
    var isToHeigh = false
    
    fileprivate override init() {
        super.init()
    }
    
    fileprivate struct Inner {
        static var regulationBright: RegulationBrightness?
        static var onceToken: Int = 0
    }
    
    static func sharedBrightness() -> RegulationBrightness {
        
        _ = RegulationBrightness.__once
        
        return Inner.regulationBright!
    }
    
    func startBrightTimer(_ isToHeigh: Bool) {
    
        if isToHeigh {
            systemBrightness = UIScreen.main.brightness
        }
        
        self.isToHeigh = isToHeigh
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(RegulationBrightness.regulationBrightnessToHeigh(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    func stopBrightTimer() {
        
        timer?.invalidate()
        timer = nil
    }
    
    func regulationBrightnessToHeigh(_ timer: Timer) {
        
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
        
        UIScreen.main.brightness = preBrightness
    }
    
}
