//
//  XRRequest.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/26.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  @brief  Alamorefire封装网络请求
 *
 *  @by     黯丶野火
 **/

import Alamofire

private func xrRequest(method: Method,
                      _ URLString: URLStringConvertible,
                        parameters: [String: AnyObject]? = nil,
                        encoding: ParameterEncoding = .URL) -> Request {
    
    let UAString = "AppName-OS-Version"
    
    let cookie = "从后台带回的cookie，一般用于Session保持后台对话"
    
    return Manager.sharedInstance.request(method, URLString, parameters: parameters, encoding: .URL, headers: ["Cookie" : cookie, "User-Agent" : UAString])
}

// Objective-C 使用 XRRequest
@objc public class XRRequest: NSObject {
    
    private static let baseURLString = {
        return RequestBaseURL
    }()
    
    static func packgeParam(code requestCode: String, parameters: [String : AnyObject]? = nil) -> String? {
        
        var param: [String : AnyObject] = [:]
        
        param["code"] = requestCode // 后台协定拼接完整URL地址
        param["os"] = "iOS" // 自定义参数 系统平台
        
        let reqParam = NSMutableDictionary()
        
        if let packParam = parameters {
            reqParam.addEntriesFromDictionary(packParam)
        }
        
        if reqParam.allKeys.count > 0 {
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(reqParam, options: .PrettyPrinted)
                let jsonStr = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
                param["params"] = jsonStr
            }catch {
                // error
            }
        }
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(param, options: .PrettyPrinted)
            let jsonStr = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
            
            return jsonStr as? String
        }catch {
            return nil
        }
    }
    
    public static func postWithCodeString(method: Method, codeString: String, params: [String : AnyObject]? = nil, keyPath: String? = nil, complationHandle: ((AnyObject?, NSError?) -> Void)) -> Request? {
        
        if let dataStr = packgeParam(code: codeString, parameters: params) {
            
            var param: [String : AnyObject] = [:]
            
            param["data"] = dataStr
            
            let request = xrRequest(method, baseURLString)
            request.responseJSONSerializer(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), keyPath: keyPath, complationHandle: { (request, response, retDict, error) in
                dispatch_async(dispatch_get_main_queue(), { 
                    complationHandle(retDict, error)
                })
            })
            
            return request
        }
        
        return nil
    }
    
    public static func getWithCodeString(codeString: String, keyPath: String? = nil, complationHandle: ((AnyObject?, NSError?) -> Void)) -> Request? {
        
        if !codeString.isEmpty {
            let request = xrRequest(.GET, codeString)
            request.responseJSONSerializer(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), keyPath: keyPath, complationHandle: { (request, response, retDict, error) in
                dispatch_async(dispatch_get_main_queue(), { 
                    complationHandle(retDict, error)
                })
            })
            
            return request
        }
        
        return nil
    }
    
    
}
