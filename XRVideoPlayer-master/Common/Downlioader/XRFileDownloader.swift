//
//  XRFileDownloader.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/11/17.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 * @brief  基于URLSession封装的文件下载类
 *
 * @by     黯丶野火
 */

import UIKit
import Foundation

@objc protocol XRFileDownloaderDelegate {
    
    @objc func downloader(downloadProgress progress: Float , speed: Float , totalSize: Float) -> Swift.Void
    @objc func downloaderFinished(downloadProgress progress: Float) -> Swift.Void
}

class XRFileDownloader: NSObject, URLSessionDownloadDelegate {
    
    static let shared: XRFileDownloader = XRFileDownloader()
    open var backgroundIdentifier: String = "com.background.session"
    fileprivate var urlSession: URLSession!
    fileprivate var downloadTasks: [String : URLSessionDownloadTask] = [:] // 保存下载任务
    public var delegate: XRFileDownloaderDelegate?
    
    
    fileprivate override init() {
        super.init()
    }
    
    /**
     - 下载文件
     - 参数： URL资源地址
     */
    func downloadFile(_ urlString: String?) {
        
        guard let fileUrlString = urlString , !fileUrlString.isEmpty else {
            debugPrint("urlString is not available.")
            return
        }
        
        let downloadURL = URL(string: fileUrlString)
        
        guard let resourceURL = downloadURL else {
            return
        }
        
        urlSession = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: self.backgroundIdentifier), delegate: self, delegateQueue: OperationQueue())
        let urlRequest = URLRequest(url: resourceURL)
        let downloadTask = urlSession.downloadTask(with: urlRequest)
        downloadTask.resume()
        downloadTasks[resourceURL.absoluteString] = downloadTask
    }
    
    // MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let speed: Float = Float(bytesWritten) / 1024.0
        let recived: Float = Float(totalBytesWritten) / 1024.0
        let total: Float = Float(totalBytesExpectedToWrite) / 1024.0
        
        debugPrint("progress: \(recived / total * 100.0)% - speed: \(speed)k/s")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        debugPrint("download finished!")
    }
    
    
}





