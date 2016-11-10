////
////  XRRequest.swift
////  XRVideoPlayer-master
////
////  Created by xuran on 16/4/26.
////  Copyright © 2016年 黯丶野火. All rights reserved.
////
//
///**
// *  @brief  Alamorefire封装网络请求
// *
// *  @by     黯丶野火
// **/
//
//import Foundation
//
//// Objective-C 使用 XRRequest
//open class XRRequest: NSObject {
//    
//    fileprivate static let baseURLString = {
//        return RequestBaseURL
//    }()
//    
//    static func packgeParam(code requestCode: String, parameters: [String : AnyObject]? = nil) -> String? {
//        
//        var param: [String : AnyObject] = [:]
//        
//        param["code"] = requestCode as AnyObject? // 后台协定拼接完整URL地址
//        param["os"] = "iOS" as AnyObject? // 自定义参数 系统平台
//        
//        let reqParam = NSMutableDictionary()
//        
//        if let packParam = parameters {
//            reqParam.addEntries(from: packParam)
//        }
//        
//        if reqParam.allKeys.count > 0 {
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: reqParam, options: .prettyPrinted)
//                let jsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
//                param["params"] = jsonStr
//            }catch {
//                // error
//            }
//        }
//        
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
//            let jsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
//            
//            return jsonStr as? String
//        }catch {
//            return nil
//        }
//    }
//    
//    open static func postWithCodeString(_ method: Method, codeString: String, params: [String : AnyObject]? = nil, keyPath: String? = nil, complationHandle: ((AnyObject?, NSError?) -> Void)) -> Request? {
//        
//        if let dataStr = packgeParam(code: codeString, parameters: params) {
//            
//            var param: [String : AnyObject] = [:]
//            
//            param["data"] = dataStr as AnyObject
//            
////            let request = xrRequest(method, baseURLString)
////            request.responseJSONSerializer(dispatch_get_global_queue(DispatchQueue.GlobalQueuePriority.default, 0), keyPath: keyPath, complationHandle: { (request, response, retDict, error) in
////                DispatchQueue.main.async(execute: { 
////                    complationHandle(retDict, error)
////                })
////            })
//            
//            return request
//        }
//        
//        return nil
//    }
//    
//    open static func getWithCodeString(_ codeString: String, keyPath: String? = nil, complationHandle: ((AnyObject?, NSError?) -> Void)) -> Request? {
//        
//        if !codeString.isEmpty {
//            let request = xrRequest(.GET, codeString)
//            request.responseJSONSerializer(dispatch_get_global_queue(DispatchQueue.GlobalQueuePriority.default, 0), keyPath: keyPath, complationHandle: { (request, response, retDict, error) in
//                DispatchQueue.main.async(execute: { 
//                    complationHandle(retDict, error)
//                })
//            })
//            
//            return request
//        }
//        
//        return nil
//    }
//    
//    
//}
