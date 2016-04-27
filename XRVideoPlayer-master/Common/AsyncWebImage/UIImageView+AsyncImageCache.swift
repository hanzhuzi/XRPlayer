//
//  UIImageView+AsyncImageCache.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/27.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  图片缓存
 **/

import Foundation
import UIKit

extension UIImageView {
    
    /**
     *  从网络获取图片资源设置到UIImageView上
     **/
    public func async_setImageWithURL(URLString: String?, placeHoldImage: UIImage?) {
        
        if let placeImage = placeHoldImage {
            self.image = placeImage
        }else {
            self.image = nil
        }
        
        if URLString != nil && !URLString!.isEmpty {
            AsyncImageDownloader.sharedImageDownloader().downloadImageWithURL(URLString) { (image) in
                
                if let img = image {
                    self.image = img
                }
            }
        }else {
            if let placeImage = placeHoldImage {
                self.image = placeImage
            }else {
                self.image = nil
            }
        }
    }
    
    
    
}


