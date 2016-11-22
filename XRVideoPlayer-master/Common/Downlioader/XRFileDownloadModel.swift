//
//  XRFileDownloadModel.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/11/21.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

public enum XRFileDownloadStatus {
    
    case toReady
    case suspend
    case downloading
    case cancel
    case downloadSuccess
    case downloadFailure
}

class XRFileDownloadModel: NSObject {
    
    var urlString: String?
    var fileSession: URLSession?
    var fileBackgroundIdentifier: String?
    var fileDownloadTask: URLSessionDownloadTask?
    var status: XRFileDownloadStatus = .toReady
    var filePath: String?
    
}
