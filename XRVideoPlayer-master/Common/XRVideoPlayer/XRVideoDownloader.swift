//
//  XRVideoDownloader.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/5/4.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

class XRVideoDownloader: NSObject {
    
    open var session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    func downloadVideo(_ url: String) -> Void {
        
        let videoURL = URL(string: url)
        let request = URLRequest(url: videoURL!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            
        }) 
    }
}
