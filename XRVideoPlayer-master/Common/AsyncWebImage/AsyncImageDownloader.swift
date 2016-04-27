//
//  AsyncImageDownloader.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/27.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  图片资源下载
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
            
            operationQueue.addOperationWithBlock({ [weak self]() -> Void in
                if let weakSelf = self {
                    
                    let request = NSURLRequest(URL: NSURL(string: urlStr)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
                    let dataTask = weakSelf.URLSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                        
                        if let imageData = data {
                            let image: UIImage = UIImage(data: imageData)!
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