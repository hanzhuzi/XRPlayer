//
//  UIColor+Extension.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/28.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    public class func RGBColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    
}
