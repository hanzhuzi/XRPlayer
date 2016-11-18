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

private let requestTimeOutInterval: TimeInterval = 30.0

import Foundation
import SwiftyJSON

// Method
fileprivate enum CustomMethod: String {
    
    case GET
    case POST
    case PUT
    case DELETE
}

open class XRRequest: NSObject, URLSessionDataDelegate {
    
    open static var shared: XRRequest = XRRequest()
    fileprivate var sessionManager: URLSession!
    open var baseURLString = {
        return RequestBaseURL
    }()
    
    fileprivate override init() {
        super.init()
        
        sessionManager = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue())
    }
    
    /**
     - 封装请求参数
     - code，os，params 是与服务端商定好的请求参数，可根据服务端的不同而变化。
     */
    fileprivate static func packgeParam(code requestCode: String, parameters: [String : Any]? = nil) -> Data? {
        
        var param: [String : Any] = [:]
        
        param["code"] = requestCode // 后台协定拼接完整URL地址
        param["os"] = "iOS" // 自定义参数 系统平台
        
        // 服务端需要的params参数 params是与服务端约定好的参数
        let reqParam = NSMutableDictionary()
        
        if let packParam = parameters { // 当传入参数为nil时，则是GET请求
            reqParam.addEntries(from: packParam)
        }
        
        // 设置设备id
        reqParam["device_id"] = "deviceID"
        // ...
        
        param["params"] = "\(JSON(reqParam))"
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
            return jsonData
        }catch {
            return nil
        }
    }
    
    /**
     - 解析请求返回的数据
     */
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
     */
    open func getDataWithCode(codeString code: String? , params: [String : Any]? = nil , complete: @escaping (Any?, Error?) -> Swift.Void) -> Swift.Void {
        
        guard let codeStr = code else { return }
        
        let reqCode = baseURLString + codeStr
        guard let url = URL(string: reqCode) else {
            return
        }
        
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: requestTimeOutInterval)
        urlRequest.httpMethod = CustomMethod.GET.rawValue
        
        // httpHeaderFields
        // Cookie、 User-Agent
        var httpHeaderFields: [String : String] = [:]
        httpHeaderFields["Cookie"] = "YOUR SERVER'S SESSIONID OR TOKEN."
        httpHeaderFields["User-Agent"] = "YOUR SERVER AGENT" // eg: XRVideoPlayer-iOS-Version-1.0.0
        
        urlRequest.allHTTPHeaderFields = httpHeaderFields
        urlRequest.httpShouldHandleCookies = true // sent Cookie or set Cookie
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
    
    /**
     - POST 请求
     - params: 请求参数
     */
    open func postDataWithCode(codeString code: String? , params: [String : Any]? = nil , complete: @escaping (Any?, Error?) -> Swift.Void) -> Swift.Void {
        
        guard let codeStr = code else { return }
        
        guard let url = URL(string: baseURLString) else {
            return
        }
        
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: requestTimeOutInterval)
        urlRequest.httpMethod = CustomMethod.POST.rawValue
        urlRequest.httpBody = XRRequest.packgeParam(code: codeStr, parameters: params)
        
        // httpHeaderFields
        // Cookie、 User-Agent
        var httpHeaderFields: [String : String] = [:]
        httpHeaderFields["Cookie"] = "YOUR SERVER'S SESSIONID OR TOKEN."
        httpHeaderFields["User-Agent"] = "YOUR SERVER AGENT" // eg: XRVideoPlayer-iOS-Version-1.0.0
        
        urlRequest.allHTTPHeaderFields = httpHeaderFields
        urlRequest.httpShouldHandleCookies = true // sent Cookie or set Cookie
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
    
    /**
     - PUT
     */
    
    
    /**
     - DELETE
     */
    
    // MARK: - URLSessionDataDelegate
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        
    }
    
    
}



