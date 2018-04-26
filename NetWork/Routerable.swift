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
    var headerFields: [String: String] {get}
    
    // Optional
    var baseURL: String? {get}
    var defaultParameters: RouterParam {get}
}

// MARK: - 验证相关的信息
extension Routerable {
    /// baseURL
    var baseURL: String? {
        return nil
    }
    /// 通用参数
    var defaultParameters: RouterParam {
        return [:]
    }
    /// url
    public var url: String {
        return "\(baseURL ?? "")/\(http.0)"
    }
    /// method
    public var method: HTTPMethod {
        return http.1
    }
    /// parameters
    public var parameters: RouterParam {
        return http.2
    }
    /// 是否使用缓存
    public var useCache: Bool {
        return http.3
    }
    //    var fileName: String{
    //        let l =  URL.init(string: url)!
    //        let fileName = (l.query != nil ? (l.query!.split(separator: "=").last.map(String.init)!) : l.lastPathComponent) + ".json"
    //        return fileName
    //    }
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

