//
//  Config.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 2017/10/13.
//  Copyright © 2017年 黯丶野火. All rights reserved.
//

import Foundation

func iSiPhoneX() -> Bool {
    return (UIScreen.main.bounds.size.width == 375 && UIScreen.main.bounds.size.height == 812) || (UIScreen.main.bounds.size.width == 812 && UIScreen.main.bounds.size.height == 375)
}

func iSiPhone6_7_8() -> Bool {
    return (UIScreen.main.bounds.size.width == 375) && (UIScreen.main.bounds.size.height == 667)
}

func iSiPhone6_7_8Plus() -> Bool {
    return (UIScreen.main.bounds.size.width == 414) && (UIScreen.main.bounds.size.height == 736)
}

func iSiPhone4_4S() -> Bool {
    return (UIScreen.main.bounds.size.width == 320) && (UIScreen.main.bounds.size.height == 480)
}

func iSiPhone5_5s() -> Bool {
    return (UIScreen.main.bounds.size.width == 320) && (UIScreen.main.bounds.size.height == 568)
}



