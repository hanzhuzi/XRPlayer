//
//  AsyncImageCache.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/27.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  AsyncImageCache
 *
 *  @brief  图片缓存
 *  @by     黯丶野火
 **/

import Foundation
import UIKit
import CryptoSwift
import CoreImage

// cache type.
enum AsyncImageCacheType: String {
    
    case None
    case Disk
    case Memory
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
    var cacheType: AsyncImageCacheType = .Disk // 默认是缓存到disk.
    // 图片缓存路径
    private let cachePathDirectory = {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
    }()
    
    private let kPNGSignatureData: NSData? = nil
    
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
    
    private func imageDataHasPNGPreffix(data: NSData) -> Bool {
        let pngSignatureLength = kPNGSignatureData?.length
        
        if data.length >= pngSignatureLength && pngSignatureLength != nil {
            if data.subdataWithRange(NSMakeRange(0, pngSignatureLength!)) == kPNGSignatureData {
                return true
            }
        }
        
        return false
    }
    
    // make md5 string key.
    private func cacheFileNameForKey(key: String?) -> String? {
        
        if let md5Key = key {
            return md5Key.md5()
        }
        
        return nil
    }
    
    // cache image to disk.
    func cacheImageToDisk(image: UIImage?, imageData: NSData?, key: String?) -> Void {
        
        if let img = image where key != nil {
            
            dispatch_async(ioQueue, { [weak self]() -> Void in
                var data: NSData? = imageData
                
                if let weakSelf = self {
                    let cacheDirectory = weakSelf.cachePathDirectory
                    if let cachePath = cacheDirectory where data != nil {
                        
                        let alpaInfo = CGImageGetAlphaInfo(img.CGImage)
                        var isPng = !(alpaInfo == .None || alpaInfo == .NoneSkipFirst || alpaInfo == .NoneSkipLast) as Bool
                        
                        if data!.length >= weakSelf.kPNGSignatureData?.length {
                            isPng = weakSelf.imageDataHasPNGPreffix(data!)
                        }
                        
                        if isPng {
                            data = UIImagePNGRepresentation(img)
                        }else {
                            data = UIImageJPEGRepresentation(img, 1.0)
                        }
                        
                        // open disk cache.
                        if weakSelf.cacheType == .Disk {
                            if let imgData = data {
                                let asyncCacheDirectory = cachePath.stringByAppendingString(weakSelf.cacheHomePath)
                                if !weakSelf.fm.fileExistsAtPath(asyncCacheDirectory) {
                                    do {
                                        try weakSelf.fm.createDirectoryAtPath(asyncCacheDirectory, withIntermediateDirectories: true, attributes: nil)
                                        
                                    }catch let error as NSError {
                                        print(error)
                                    }
                                }
                                if let fileName = weakSelf.cacheFileNameForKey(key!) {
                                    let cachePathForKey = asyncCacheDirectory.stringByAppendingString("/" + fileName)
                                    
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
                            }else if weakSelf.cacheType == .Memory {
                                // user memory cache.
                                
                            }else {
                                /// not use cache.
                            }
                        
                        }
                    }
                }
            })
        }
    }
    
    // get cache image filePath.
    func getCacheFilePathWithKey(key: String?) -> String? {
        
        if let pathKey = key {
            let cacheDirectory = cachePathDirectory
            
            if let cacheDir = cacheDirectory {
                let asyncCacheDirectory = cacheDir.stringByAppendingString(cacheHomePath)
                if let fileName = cacheFileNameForKey(pathKey) {
                    let cachePathForKey = asyncCacheDirectory.stringByAppendingString("/" + fileName)
                    return cachePathForKey
                }
            }
        }
        
        return nil
    }
    
    // check the cache image is exsist.
    func disImageIsExsistWithKey(key: String?) -> Bool {
        
        var isExsist = false
        let cacheFilePath = getCacheFilePathWithKey(key)
        if let cachePath = cacheFilePath {
            isExsist = fm.fileExistsAtPath(cachePath)
            
            if !isExsist {
                isExsist = fm.fileExistsAtPath((cachePath as NSString).stringByDeletingPathExtension)
            }
        }
        
        return isExsist
    }
    
    
}
