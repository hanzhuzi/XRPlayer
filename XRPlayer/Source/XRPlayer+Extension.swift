//
//  XRPlayer+Extension.swift
//  XRPlayer
//
//  Created by xuran on 2019/11/12.
//  Copyright © 2019 xuran. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {

    /// 配置普通Button
    func configButtonForNormal(title: String?, textAlignment: NSTextAlignment = .center, textColor: UIColor?, font: UIFont?, normalImage: UIImage?, selectedImage: UIImage?,  backgroundColor: UIColor?) {
        
        self.backgroundColor = backgroundColor
        self.setTitleColor(textColor, for: UIControl.State.normal)
        self.setTitleColor(textColor, for: [.normal, .highlighted])
        self.setTitle(title, for: UIControl.State.normal)
        self.setTitle(title, for: [.normal, .highlighted])
        
        self.setImage(normalImage, for: UIControl.State.normal)
        self.setImage(normalImage, for: UIControl.State.highlighted)
        self.setImage(selectedImage, for: UIControl.State.selected)
        self.titleLabel?.textAlignment = textAlignment
        self.titleLabel?.font = font
    }

    /// 配置按钮，button title 普通\选中状态
    func configButtonForTitleState(title: String?, textAlignment: NSTextAlignment = .center, font: UIFont?, backgroundColor: UIColor?, normalTextColor: UIColor?, selectedTextColor: UIColor?) {
        
        self.backgroundColor = backgroundColor
        self.setTitle(title, for: UIControl.State.normal)
        self.setTitle(title, for: UIControl.State.selected)
        self.setTitleColor(normalTextColor, for: UIControl.State.normal)
        self.setTitleColor(normalTextColor, for: [.normal, .highlighted])
        self.setTitleColor(selectedTextColor, for: UIControl.State.selected)
        self.setTitleColor(selectedTextColor, for: [.selected, .highlighted])
        self.titleLabel?.textAlignment = textAlignment
        self.titleLabel?.font = font
    }

    /// 配置按钮，button image 普通\选中状态
    func configButtonForImageState(normalImage: UIImage?, selectedImage: UIImage?,  backgroundColor: UIColor?) {
        
        self.backgroundColor = backgroundColor
        self.setImage(normalImage, for: .normal)
        self.setImage(selectedImage, for: .selected)
    }
    
}



