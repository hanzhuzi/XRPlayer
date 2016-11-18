//
//  XRRequest.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/26.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 * @brief  URLSession封装网络请求
 *
 * @by     黯丶野火
 */

private let requestTimeOutInterval: TimeInterval = 60.0

import Foundation

open class XRRequest: NSObject {
    
    fileprivate static let sessionManager: URLSession = URLSession.shared
    fileprivate static let baseURLString = {
        return RequestBaseURL
    }()
    
    /**
     - 封装请求参数
     */
    fileprivate static func packgeParam(code requestCode: String, parameters: [String : AnyObject]? = nil) -> String? {
        
        var param: [String : AnyObject] = [:]
        
        param["code"] = requestCode as AnyObject? // 后台协定拼接完整URL地址
        param["os"] = "iOS" as AnyObject? // 自定义参数 系统平台
        
        let reqParam = NSMutableDictionary()
        
        if let packParam = parameters {
            reqParam.addEntries(from: packParam)
        }
        
        if reqParam.allKeys.count > 0 {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: reqParam, options: .prettyPrinted)
                let jsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
                param["params"] = jsonStr
            }catch {
                // error
            }
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
            let jsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            
            return jsonStr as? String
        }catch {
            return nil
        }
    }
    
    fileprivate static func parseResultData(reqData data: Data? , complation: (Any?, Error?) ->Swift.Void) {
        
        if let resData = data {
            do {
                let resultObj = try JSONSerialization.jsonObject(with: resData, options: .allowFragments)
                complation(resultObj, nil)
            }
            catch let terror {
                complation(nil, terror)
            }
        }
        else {
            complation(nil, nil)
        }
    }
    
    /**
     - GET 请求
     - params can be nil
     */
    open static func getDataFromURL(codeString code: String? , params: [String : Any]? = nil , complete: @escaping (Any?, Error?) -> Swift.Void) -> Swift.Void {
        
        guard let codeStr = code else { return }
        
        let reqCode = baseURLString + codeStr
        guard let url = URL(string: reqCode) else {
            return
        }
        
        let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: requestTimeOutInterval)
        sessionManager.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil {
                XRRequest.parseResultData(reqData: data, complation: { (resObj, err) in
                    complete(resObj, err)
                })
            }
            else {
                complete(nil, error)
            }
        }.resume()
        
    }
    
    
}
