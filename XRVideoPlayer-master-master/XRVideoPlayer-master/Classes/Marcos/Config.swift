//
//  Config.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 2017/10/13.
//  Copyright © 2017年 黯丶野火. All rights reserved.
//

import Foundation

func iSiPhoneX() -> Bool {
    return (UIScreen.main.bounds.size.width == 375) && (UIScreen.main.bounds.size.height == 812)
}

func iSiPhone6_7_8() -> Bool {
    return (UIScreen.main.bounds.size.width == 375) && (UIScreen.main.bounds.size.height == 667)
}


