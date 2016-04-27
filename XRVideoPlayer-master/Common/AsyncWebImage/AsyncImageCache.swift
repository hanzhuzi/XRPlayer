//
//  AsyncImageCache.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/27.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift
import CoreImage

// 图片缓存路径
private let cachePathDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first

private let kPNGSignatureData: NSData? = nil

private func imageDataHasPNGPreffix(data: NSData) -> Bool {
    let pngSignatureLength = kPNGSignatureData?.length
    
    if data.length >= pngSignatureLength && pngSignatureLength != nil {
        if data.subdataWithRange(NSMakeRange(0, pngSignatureLength!)) == kPNGSignatureData {
            return true
        }
    }
    
    return false
}

class AsyncImageCache: NSObject {
    
    private var urlKey: String?
    private var cacheFilePath: String?
    private var fm: NSFileManager = {
        return NSFileManager.defaultManager()
    }()
    lazy private var ioQueue: dispatch_queue_t = dispatch_queue_create("cache.image.queue", DISPATCH_QUEUE_SERIAL)
    private var shouldDisableiCloud: Bool = false
    private let cacheHomePath: String = {
        return "/com.async.cacheImage"
    }()
    
    private struct Inner {
        static var onceToken: dispatch_once_t = 0
        static var instence: AsyncImageCache?
    }
    
    private override init() {
        super.init()
    }
    
    static func sharedCache() -> AsyncImageCache {
        
        dispatch_once(&Inner.onceToken) { 
            if Inner.instence == nil {
                Inner.instence = AsyncImageCache()
            }
        }
        
        return Inner.instence!
    }
    
    func cacheFileNameForKey(key: String) -> String {
        
        return key.md5()
    }
    
    // 缓存图片到磁盘
    func cacheImageToDisk(image: UIImage?, imageData: NSData?, key: String?) -> Void {
        
        if let img = image where key != nil {
            
            dispatch_async(ioQueue, { [weak self]() -> Void in
                var data: NSData? = imageData
                
                if let weakSelf = self {
                    let cacheDirectory = cachePathDirectory
                    if let cachePath = cacheDirectory where data != nil {
                        
                        let alpaInfo = CGImageGetAlphaInfo(img.CGImage)
                        var isPng = !(alpaInfo == .None || alpaInfo == .NoneSkipFirst || alpaInfo == .NoneSkipLast) as Bool
                        
                        if data!.length >= kPNGSignatureData?.length {
                            isPng = imageDataHasPNGPreffix(data!)
                        }
                        
                        if isPng {
                            data = UIImagePNGRepresentation(img)
                        }else {
                            data = UIImageJPEGRepresentation(img, 1.0)
                        }
                        
                        if let imgData = data {
                            let asyncCacheDirectory = cachePath.stringByAppendingString(weakSelf.cacheHomePath)
                            if !weakSelf.fm.fileExistsAtPath(asyncCacheDirectory) {
                                do {
                                    try weakSelf.fm.createDirectoryAtPath(asyncCacheDirectory, withIntermediateDirectories: true, attributes: nil)
                                    
                                }catch let error as NSError {
                                    print(error)
                                }
                            }
                            
                            let cachePathForKey = asyncCacheDirectory.stringByAppendingString("/" + weakSelf.cacheFileNameForKey(key!))
                            print("cachePath: \(cachePathForKey)")
                            let fileURL: NSURL = NSURL(fileURLWithPath: cachePathForKey)
                            weakSelf.fm.createFileAtPath(cachePathForKey, contents: imgData, attributes: nil)
                            
                            // disable iCloud backup
                            if weakSelf.shouldDisableiCloud {
                                // iCloud 备份
                                do {
                                    try fileURL.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
                                }catch let error as NSError {
                                    print(error)
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    // 检查缓存的图片是否存在
    func disImageIsExsistWithKey(key: String?) -> Bool {
        
        let isExsist = false
        
        return isExsist
    }
    
    
}
