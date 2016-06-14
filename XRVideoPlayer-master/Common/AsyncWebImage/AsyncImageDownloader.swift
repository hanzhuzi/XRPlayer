//
//  AsyncImageDownloader.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/27.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  AsyncImageDownloader
 *
 *  @brief  图片资源下载
 *  @by     黯丶野火
 **/

import Foundation
import UIKit

class AsyncImageDownloader: NSObject {
    
    private lazy var URLSession: NSURLSession = {
        let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        return session
    }()
    
    private lazy var operationQueue: NSOperationQueue = NSOperationQueue()
    
    deinit {
        operationQueue.cancelAllOperations()
    }
    
    private override init() {
        super.init()
        
        operationQueue.maxConcurrentOperationCount = 6
    }
    
    private struct Inner {
        static var onceToken: dispatch_once_t = 0
        static var imageDownloader: AsyncImageDownloader?
    }
    
    static func sharedImageDownloader() -> AsyncImageDownloader {
        
        dispatch_once(&Inner.onceToken) {
            if Inner.imageDownloader == nil {
                Inner.imageDownloader = AsyncImageDownloader()
            }
        }
        
        return Inner.imageDownloader!
    }
    
    func downloadImageWithURL(URLString: String?, complationHandle: ((image: UIImage?) -> Void)) {
        
        if let urlStr = URLString {
            
            // 检测图片是否缓存了
            if AsyncImageCache.sharedCache().disImageIsExsistWithKey(urlStr) {
                let cacheFilePath = AsyncImageCache.sharedCache().getCacheFilePathWithKey(urlStr)
                if let cachePath = cacheFilePath {
                    // 取出本地缓存好的图片
                    operationQueue.addOperationWithBlock({ 
                        let cacheImage = UIImage(contentsOfFile: cachePath)
                        dispatch_async(dispatch_get_main_queue(), { 
                            complationHandle(image: cacheImage)
                        })
                    })
                }
            }else {
                operationQueue.addOperationWithBlock({ [weak self]() -> Void in
                    if let weakSelf = self {
                        
                        let request = NSURLRequest(URL: NSURL(string: urlStr)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
                        
                        let dataTask = weakSelf.URLSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                            
                            if let imageData = data {
                                let image = UIImage.init(data: imageData)
                                AsyncImageCache.sharedCache().cacheImageToDisk(image, imageData: imageData, key: urlStr)
                                dispatch_async(dispatch_get_main_queue(), {
                                    complationHandle(image: image)
                                })
                            }
                        })
                        
                        dataTask.resume()
                    }
                    })
            }
        }
    }
    
    
}