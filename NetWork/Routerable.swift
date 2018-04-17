//
//  Routerable.swift
//  KF5Swift
//
//  Created by admin on 17/6/28.
//  Copyright © 2017年 ma. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public typealias RouterParam = Parameters
public typealias RouterMethod = HTTPMethod

// MARK: - Routerable
public protocol Routerable{
    // url, method, param, useCache
    var http : (String, RouterMethod, RouterParam, Bool) {get}
}

// MARK: - 验证相关的信息
extension Routerable {
    public var baseURL: String {
        return (UserDefaults.standard.value(forKey: "hostName")) as? String  ?? ""
    }
    /// url
    public var url: String {
        return "\(baseURL)/\(http.0)"
    }
    /// method
    public var method: HTTPMethod {
        return http.1
    }
    /// 是否使用缓存
    public var useCache: Bool {
        return http.3
    }
    /// header
    public var headerFields: [String: String]{
        var header: [String:String] = [:]
        
        header["version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        header["type"] = "ios"
        header["Content-Type"] = "application/json"
        return header
    }
    /// parameters
    public var parameters: Parameters {
        var newParams: Parameters = self.http.2
        //添加服务器版本
        newParams["version"] = "1.9"
        return newParams
    }
    var fileName: String{
        let l =  URL.init(string: url)!
        let fileName = (l.query != nil ? (l.query!.split(separator: "=").last.map(String.init)!) : l.lastPathComponent) + ".json"
        return fileName
    }
}

extension Routerable {
    @discardableResult
    public func requestResult(queue: DispatchQueue? = DispatchQueue.global(),isShowError: Bool = true, completionHandler: @escaping (Result<JSON>, Bool) -> Void) -> DataRequest {
        return HttpManager.requestResult(router: self, queue: queue, isShowError: isShowError, completionHandler: completionHandler)
    }
    @discardableResult
    public func request(queue: DispatchQueue? = DispatchQueue.global(),isShowError: Bool = true, completionHandler: @escaping (DataResponse<JSON>, Bool) -> Void) -> DataRequest {
        return HttpManager.request(router: self, queue: queue, isShowError: isShowError, completionHandler: completionHandler)
    }
}
