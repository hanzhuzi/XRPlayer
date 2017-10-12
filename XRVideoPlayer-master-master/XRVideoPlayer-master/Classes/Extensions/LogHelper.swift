//
//  LogHelper.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 17/6/21.
//  Copyright © 2017年 黯丶野火. All rights reserved.
//

import Foundation

extension NSDictionary {
    
    // 打印JSON字符串Log
    func logJSONString() -> String? {
        
        var jsonString: String?
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
            jsonString = String(data: data, encoding: String.Encoding.utf8)
        }
        catch let error as NSError {
            jsonString = String(format: "reason: %@, JSON: %@", error.localizedFailureReason!, self.description)
        }
        return jsonString
    }
}
