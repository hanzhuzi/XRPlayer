//
//  UIImageView+AsyncImageCache.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/27.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  UIImageView+AsyncImageCache
 *
 *  @brief  从网络获取图片资源并设置到UIImageView上，图片将缓存到磁盘.
 *  @by     黯丶野火
 **/

import Foundation
import UIKit

extension UIImageView {
    
    // set image to UIImageView.
    public func async_setImageWithURL(_ URLString: String?, placeHoldImage: UIImage?) {
        
        if let placeImage = placeHoldImage {
            self.image = placeImage
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


