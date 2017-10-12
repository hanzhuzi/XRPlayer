////
////  AsyncImageCache.swift
////  XRVideoPlayer-master
////
////  Created by xuran on 16/4/27.
////  Copyright © 2016年 黯丶野火. All rights reserved.
////
//
///**
// *  AsyncImageCache
// *
// *  @brief  图片缓存
// *  @by     黯丶野火
// **/
//
//import Foundation
//import UIKit
//import CryptoSwift
//import CoreImage
//fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l < r
//  case (nil, _?):
//    return true
//  default:
//    return false
//  }
//}
//
//fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l >= r
//  default:
//    return !(lhs < rhs)
//  }
//}
//
//
//// cache type.
//enum AsyncImageCacheType: String {
//    
//    case None
//    case Disk
//    case Memory
//}
//
//class AsyncImageCache: NSObject {
//    
//    private static var __once: () = { 
//            if Inner.instence == nil {
//                Inner.instence = AsyncImageCache()
//            }
//        }()
//    
//    fileprivate var urlKey: String?
//    fileprivate var cacheFilePath: String?
//    fileprivate var fm: FileManager = {
//        return FileManager.default
//    }()
//    lazy fileprivate var ioQueue: DispatchQueue = DispatchQueue(label: "cache.image.queue", attributes: [])
//    fileprivate var shouldDisableiCloud: Bool = false
//    fileprivate let cacheHomePath: String = {
//        return "/com.async.cacheImage"
//    }()
//    var cacheType: AsyncImageCacheType = .Disk // 默认是缓存到disk.
//    // 图片缓存路径
//    fileprivate let cachePathDirectory = {
//        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
//    }()
//    
//    fileprivate let kPNGSignatureData: Data? = nil
//    
//    fileprivate struct Inner {
//        static var onceToken: Int = 0
//        static var instence: AsyncImageCache?
//    }
//    
//    fileprivate override init() {
//        super.init()
//    }
//    
//    static func sharedCache() -> AsyncImageCache {
//        
//        _ = AsyncImageCache.__once
//        
//        return Inner.instence!
//    }
//    
//    fileprivate func imageDataHasPNGPreffix(_ data: Data) -> Bool {
//        let pngSignatureLength = kPNGSignatureData?.count
//        
//        if data.count >= pngSignatureLength && pngSignatureLength != nil {
//            if data.subdata(with: NSMakeRange(0, pngSignatureLength!)) == kPNGSignatureData {
//                return true
//            }
//        }
//        
//        return false
//    }
//    
//    // make md5 string key.
//    fileprivate func cacheFileNameForKey(_ key: String?) -> String? {
//        
//        if let md5Key = key {
//            return md5Key.md5()
//        }
//        
//        return nil
//    }
//    
//    // cache image to disk.
//    func cacheImageToDisk(_ image: UIImage?, imageData: Data?, key: String?) -> Void {
//        
//        if let img = image , key != nil {
//            
//            ioQueue.async(execute: { [weak self]() -> Void in
//                var data: Data? = imageData
//                
//                if let weakSelf = self {
//                    let cacheDirectory = weakSelf.cachePathDirectory
//                    if let cachePath = cacheDirectory , data != nil {
//                        
//                        let alpaInfo = (img.CGImage).alphaInfo
//                        var isPng = !(alpaInfo == .None || alpaInfo == .NoneSkipFirst || alpaInfo == .NoneSkipLast) as Bool
//                        
//                        if data!.count >= weakSelf.kPNGSignatureData?.count {
//                            isPng = weakSelf.imageDataHasPNGPreffix(data!)
//                        }
//                        
//                        if isPng {
//                            data = UIImagePNGRepresentation(img)
//                        }else {
//                            data = UIImageJPEGRepresentation(img, 1.0)
//                        }
//                        
//                        // open disk cache.
//                        if weakSelf.cacheType == .Disk {
//                            if let imgData = data {
//                                let asyncCacheDirectory = cachePath + weakSelf.cacheHomePath
//                                if !weakSelf.fm.fileExists(atPath: asyncCacheDirectory) {
//                                    do {
//                                        try weakSelf.fm.createDirectory(atPath: asyncCacheDirectory, withIntermediateDirectories: true, attributes: nil)
//                                        
//                                    }catch let error as NSError {
//                                        print(error)
//                                    }
//                                }
//                                if let fileName = weakSelf.cacheFileNameForKey(key!) {
//                                    let cachePathForKey = asyncCacheDirectory + ("/" + fileName)
//                                    
//                                    let fileURL: URL = URL(fileURLWithPath: cachePathForKey)
//                                    weakSelf.fm.createFile(atPath: cachePathForKey, contents: imgData, attributes: nil)
//                                    
//                                    // disable iCloud backup
//                                    if weakSelf.shouldDisableiCloud {
//                                        // iCloud 备份
//                                        do {
//                                            try (fileURL as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
//                                        }catch let error as NSError {
//                                            print(error)
//                                        }
//                                    }
//                                }
//                            }else if weakSelf.cacheType == .Memory {
//                                // user memory cache.
//                                
//                            }else {
//                                /// not use cache.
//                            }
//                        
//                        }
//                    }
//                }
//            })
//        }
//    }
//    
//    // get cache image filePath.
//    func getCacheFilePathWithKey(_ key: String?) -> String? {
//        
//        if let pathKey = key {
//            let cacheDirectory = cachePathDirectory
//            
//            if let cacheDir = cacheDirectory {
//                let asyncCacheDirectory = cacheDir + cacheHomePath
//                if let fileName = cacheFileNameForKey(pathKey) {
//                    let cachePathForKey = asyncCacheDirectory + ("/" + fileName)
//                    return cachePathForKey
//                }
//            }
//        }
//        
//        return nil
//    }
//    
//    // check the cache image is exsist.
//    func disImageIsExsistWithKey(_ key: String?) -> Bool {
//        
//        var isExsist = false
//        let cacheFilePath = getCacheFilePathWithKey(key)
//        if let cachePath = cacheFilePath {
//            isExsist = fm.fileExists(atPath: cachePath)
//            
//            if !isExsist {
//                isExsist = fm.fileExists(atPath: (cachePath as NSString).deletingPathExtension)
//            }
//        }
//        
//        return isExsist
//    }
//    
//    
//}
