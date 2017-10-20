//
//  String+Extension.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 2017/10/18.
//  Copyright © 2017年 黯丶野火. All rights reserved.
//

import Foundation

extension String {
    
    // URL Encoding
    // 对URL链接地址中的中文及特殊字符进行转码
    // 先去掉编码再进行编码，防止二次编码
    func urlEncoding() -> String? {
        if let urlStr = self.removingPercentEncoding {
            return urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        }
        return nil
    }
    
    // URL Decoding
    // 解码URL链接中的中文路径
    func urlDecoding() -> String? {
        return self.removingPercentEncoding
    }
    
}
