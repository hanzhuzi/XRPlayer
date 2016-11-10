////
////  Alamofire+Extension.swift
////  XRVideoPlayer-master
////
////  Created by xuran on 16/4/26.
////  Copyright © 2016年 黯丶野火. All rights reserved.
////
//
///**
// *  @brief  Alamofire 扩展
// *
// *  @by     黯丶野火
// **/
//
//import Foundation
//
//extension Request {
//    
//    // 解析
//    public class func responseJSONSerializer() -> Response<AnyObject, NSError> {
//        
//        return ResponseSerializer { _, _, data, error in
//            
//            guard error == nil else { return .Failure(error!) }
//            
//            guard let ralData = data , ralData.length > 0 else {
//                
//                let failureReason = "JSON could not be serialized. Input data was nil or zero length."
//                let error = Error.error(code: .DataSerializationFailed, failureReason: failureReason)
//                return .Failure(error)
//            }
//            
//            do {
//            
//                let JSON = try NSJSONSerialization.JSONObjectWithData(ralData, options: .AllowFragments)
//                
//                if JSON is NSDictionary {
//                    // 是json格式
//                    let retJSON = JSON as! NSDictionary
//                    return .Success(retJSON)
//                }else {
//                    // 不是json格式
//                    let error = NSError(domain: CustomErrorDomain, code: Int(CustomErrorCodeTypeUNJSON.rawValue), userInfo: nil)
//                    return .Failure(error)
//                }
//            } catch let error as NSError {
//                
//                // JSON解析失败
//                return .Failure(error)
//            }
//        }
//    }
//    
//    
//    public func responseJSONSerializer(_ queue: dispatch_queue_t?, keyPath: String? = nil, complationHandle: (NSURLRequest?, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) -> Self {
//        
//        return response(queue: queue) { request, response, data, error -> Void in
//            
//            let jsonResponseSerializer = Request.responseJSONSerializer()
//            let result = jsonResponseSerializer.serializeResponse(request, response, data, error)
//            
//            if result.error != nil {
//                dispatch_async(dispatch_get_main_queue(), { 
//                    complationHandle(request!, response, nil, error)
//                })
//            }else if result.value != nil {
//                
//                let dict = result.value
//                complationHandle(request!, response, dict, nil)
//            }
//        }
//    }
//    
//    
//    
//    
//    
//    
//    
//}
