//
//  XRPlayerMarcos.swift
//  XRPlayer
//
//  Created by 徐冉 on 2019/7/30.
//  Copyright © 2019 QK. All rights reserved.
//

import UIKit
import Foundation

// MARK: - Print
#if DEBUG
func XRPlayerLog(_ items: Any...) {
    
    print(items)
}
#else
func XRPlayerLog(_ items: Any...) {
    
}
#endif

//MARK: - 屏幕尺寸
// iPhone5, 5S,5C,SE
public func xrPlayer_iSiPhone5_5S_5C_SE() -> Bool {
    
    return (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(UIScreen.main.currentMode!.size, CGSize(width: 640, height: 1136)) : false) || (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(UIScreen.main.currentMode!.size, CGSize(width: 1136, height: 640)) : false)
}

// iPhone6,6S,7,8
public func xrPlayer_iSiPhone6_6S_7_8() -> Bool {
    
    return (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(UIScreen.main.currentMode!.size, CGSize(width: 750, height: 1334)) : false) || (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(UIScreen.main.currentMode!.size, CGSize(width: 1334, height: 750)) : false)
}

// iPhone6, 7, 8,Plus
public func xrPlayer_iSiPhone6_7_8Plus() -> Bool {
    
    return (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(UIScreen.main.currentMode!.size, CGSize(width: 1242, height: 2208)) : false) || (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(UIScreen.main.currentMode!.size, CGSize(width: 2208, height: 1242)) : false)
}

// iPhoneX, XS
public func xrPlayer_iSiPhoneX_XS() -> Bool {
    
    return (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(UIScreen.main.currentMode!.size, CGSize(width: 1125, height: 2436)) : false) || (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(UIScreen.main.currentMode!.size, CGSize(width: 2436, height: 1125)) : false)
}

// iPhoneXR
public func xrPlayer_iSiPhoneXR() -> Bool {
    
    return (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(UIScreen.main.currentMode!.size, CGSize(width: 828, height: 1792)) : false) || (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(UIScreen.main.currentMode!.size, CGSize(width: 1792, height: 828)) : false)
}

// iPhoneXS_Max
public func xrPlayer_iSiPhoneXS_Max() -> Bool {
    
    return (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(UIScreen.main.currentMode!.size, CGSize(width: 1242, height: 2688)) : false) || (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(UIScreen.main.currentMode!.size, CGSize(width: 2688, height: 1242)) : false)
}

// 是否有齐刘海和虚拟指示器
public func xrPlayer_iSiPhoneXSerries() -> Bool {
    
    var isiPhoneXSerries: Bool = false
    
    if UIDevice.current.userInterfaceIdiom != .phone {
        isiPhoneXSerries = false
    }
    
    if #available(iOS 11.0, *) {
        if let mainWindow = UIApplication.shared.delegate?.window {
            if mainWindow!.safeAreaInsets.bottom > 0 {
                isiPhoneXSerries = true
            }
        }
    }
    
    isiPhoneXSerries = xrPlayer_iSiPhoneX_XS() || xrPlayer_iSiPhoneXR() || xrPlayer_iSiPhoneXS_Max()
    
    return isiPhoneXSerries
}

// 加载XRPlayer Bundle中的图片
func xrplayer_imageForBundleResource(imageName: String, bundleClass: AnyClass) -> UIImage? {
    
    let moduleBundle = Bundle(for: bundleClass)
    if let resourceUrl = moduleBundle.resourceURL?.appendingPathComponent("XRPlayer.bundle") {
        let resourceBundle = Bundle(url: resourceUrl)
        let resImage = UIImage(named: imageName, in: resourceBundle, compatibleWith: nil)
        return resImage
    }
    
    return nil
}

//MARK: - 颜色
// 颜色(RGB)
public func xrplayer_RGBA (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor
{
    return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

public func  xrplayer_RGBCOLOR(r:CGFloat, g:CGFloat, b:CGFloat) -> UIColor
{
    return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
}

//RGB颜色转换（16进制）
public func xrplayer_UIColorFromRGB(hexRGB: UInt32) -> UIColor
{
    let redComponent = (hexRGB & 0xFF0000) >> 16
    let greenComponent = (hexRGB & 0x00FF00) >> 8
    let blueComponent = hexRGB & 0x0000FF
    
    return xrplayer_RGBCOLOR(r: CGFloat(redComponent), g: CGFloat(greenComponent), b: CGFloat(blueComponent))
}

///延迟 afTime, 回调 block(in main 在主线程)
public func xrplayer_dispatch_after_in_main(_ afTime: TimeInterval,block: @escaping ()->()) {
    let popTime = DispatchTime.now() + Double(Int64(afTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC) // 1s * popTime
    
    if popTime > DispatchTime(uptimeNanoseconds: 0) {
        DispatchQueue.main.asyncAfter(deadline: popTime, execute: block)
    }
}
