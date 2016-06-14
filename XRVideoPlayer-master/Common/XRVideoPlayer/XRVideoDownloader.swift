//
//  XRVideoDownloader.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/5/4.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

class XRVideoDownloader: NSObject {
    
    lazy private var session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    func downloadVideo(url: String) -> Void {
        
        let videoURL = NSURL(string: url)
        let request = NSURLRequest(URL: videoURL!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        session.dataTaskWithRequest(request) { (data, response, error) in
            
        }
    }
}
