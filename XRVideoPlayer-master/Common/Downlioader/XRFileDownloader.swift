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

@objc protocol XRFileDownloaderDelegate: NSObjectProtocol {
    
    @objc func downloader(downloadProgress progress: Float , speedOfKB: Float , totalSizeOfKB: Float) -> Swift.Void
    @objc func downloaderFinished(downloadProgress progress: Float, downloadTask: URLSessionDownloadTask, location: URL) -> Swift.Void
}

extension URLSessionTask.State {
    
    func stateStringFromRawValue() -> String {
        
        switch self.rawValue {
        case 0:
            return String(format: "code: %d status: %@", self.rawValue, "running")
        case 1:
            return String(format: "code: %d status: %@", self.rawValue, "suspend")
        case 2:
            return String(format: "code: %d status: %@", self.rawValue, "canceling")
        case 3:
            return String(format: "code: %d status: %@", self.rawValue, "complete")
        default:
            return "unkown"
        }
    }
}

class XRFileDownloader: NSObject, URLSessionDownloadDelegate {
    
    static let shared: XRFileDownloader = XRFileDownloader()
    open var backgroundIdentifier: String = "com.background.session.default"
    fileprivate var urlSessions: [String : URLSession] = [:]
    fileprivate var downloadTasks: [String : URLSessionDownloadTask] = [:]
    open weak var delegate: XRFileDownloaderDelegate?
    open var downloadModelArray: [XRFileDownloadModel] = []
    open var downloadProgressClosure: (([XRFileDownloadModel]) -> Swift.Void)?
    open var downloadFinishedClosure: (([XRFileDownloadModel] , URL) -> Swift.Void)?
    
    fileprivate override init() {
        super.init()
    }
    
    /**
     - 下载文件
     - 参数： URL资源地址
     */
    func downloadFile(_ title: String? , urlString: String?) -> XRFileDownloader {
        
        guard let fileUrlString = urlString , !fileUrlString.isEmpty else {
            debugPrint("urlString is not available.")
            return XRFileDownloader.shared
        }
        
        let downloadURL = URL(string: fileUrlString)
        
        guard let resourceURL = downloadURL else {
            return XRFileDownloader.shared
        }
        
        if downloadTasks[fileUrlString] != nil {
            debugPrint("任务已经存在了")
            return XRFileDownloader.shared
        }
        
        // 设置URLString作为backgroundIdentifier
        self.backgroundIdentifier = resourceURL.absoluteString
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: self.backgroundIdentifier), delegate: self, delegateQueue: OperationQueue())
        let urlRequest = URLRequest(url: resourceURL)
        let downloadTask = urlSession.downloadTask(with: urlRequest)
        downloadTask.resume()
        urlSessions[resourceURL.absoluteString] = urlSession
        downloadTasks[resourceURL.absoluteString] = downloadTask
        
        let downloadModel = XRFileDownloadModel()
        downloadModel.title = title
        downloadModel.urlString = downloadURL?.absoluteString
        downloadModel.fileDownloadTask = downloadTask
        downloadModelArray.append(downloadModel)
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NNKEY_DOWNLOAD_ADD_TO_LIST)))
        
        return XRFileDownloader.shared
    }
    
    /**
     - 暂停下载
     - 参数：URL地址
     */
    func suspendDownload(urlString: String?) {
        
        if let urlStr = urlString {
            let downloadTask = downloadTasks[urlStr]
            debugPrint("state: \(downloadTask!.state.stateStringFromRawValue())")
            downloadTask?.suspend()
        }
    }
    
    /**
     - 继续下载
     - 参数： URL地址
     */
    func resumeDownload(urlString: String?) {
         
        if let urlStr = urlString {
            let downloadTask = downloadTasks[urlStr]
            downloadTask?.resume()
            debugPrint("state: \(downloadTask!.state.stateStringFromRawValue())")
        }
    }
    
    // MARK: - URLSessionDownloadDelegate
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let speed: Float = Float(bytesWritten) / 1024.0
        let recived: Float = Float(totalBytesWritten) / 1024.0
        let total: Float = Float(totalBytesExpectedToWrite) / 1024.0 // (KB)
        
        if let urlStr = downloadTask.response?.url?.absoluteString {
            for model in downloadModelArray {
                if model.urlString == urlStr {
                    model.speed = speed
                    model.recivedSize = recived
                    model.totalSize = total
                    model.progress = recived / total
                }
            }
        }
        
        if let downClosure = self.downloadProgressClosure {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: { [weak self] in
                if let weakSelf = self {
                    downClosure(weakSelf.downloadModelArray)
                }
            })
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        if let urlStr = downloadTask.response?.url?.absoluteString {
            if let task = downloadTasks[urlStr] {
                task.cancel()
                downloadTasks.removeValue(forKey: urlStr)
                for model in downloadModelArray {
                    if model.urlString == urlStr {
                        model.progress = 1.0
                    }
                }
                if let downClosure = downloadFinishedClosure {
                    DispatchQueue.main.sync(execute: {
                        downClosure(downloadModelArray , location)
                    })
                }
            }
        }
    }
    
    
}





