//
//  Alamofire+Custom.swift
//  KF5Swift
//
//  Created by admin on 2017/7/6.
//  Copyright © 2017年 ma. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension AFError {
    public var errorDescription: String {
        if case let .responseSerializationFailed(ResponseSerializationFailureReason.customSerializationFailed(error)) = self, let customError = error as? MAError, let description = customError.errorDescription {
            return description
        }
        return "Connect error"
    }
    public var errorCode: Int {
        if case let .responseSerializationFailed(ResponseSerializationFailureReason.customSerializationFailed(error)) = self, let customError = error as? MAError {
            return customError.errorCode
        }
        return 100
    }
}

public struct MAError: LocalizedError {
    public var errorDescription: String?
    public var errorCode: Int
    
    init(errorCode: Int, message: String) {
        self.errorCode = errorCode
        self.errorDescription = message
    }
}


public final class DictResponseSerializer: ResponseSerializer {
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> JSON {
        guard error == nil else { throw error! }

        guard var data = data, !data.isEmpty else {
            guard emptyResponseAllowed(forRequest: request, response: response) else {
                throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
            }
            return JSON()
        }

        data = try dataPreprocessor.preprocess(data)
        do {
            let json = try JSON(data: data)
            let errCode = json["error"].intValue
            let message = json["message"].stringValue
            if errCode == 0 {
                return json
            }else{
                let error = AFError.responseSerializationFailed(reason: .customSerializationFailed(error: MAError.init(errorCode: errCode, message: message)))
                throw error
            }
        } catch let error{
           throw error
        }
    }
}
// MARK: - Alamofire扩展
extension DataRequest {
    @discardableResult
    public func responseDict(
        router: Routerable, queue: DispatchQueue = .main,
        completionHandler: @escaping (AFDataResponse<JSON>) -> Void) -> Self{
        response(queue: queue , responseSerializer: DictResponseSerializer(), completionHandler: completionHandler)
        
        return self
    }
    
    /// 获取缓存
    ///
    /// - Parameter router: 请求路由
    /// - Returns: 返回结果
    func cacheRequest(router: Routerable) -> AFDataResponse<JSON>?  {
        if let request = self.request, request.httpMethod?.lowercased() == "get", let cachedReponse = HttpManager.shared.urlCache.cachedResponse(for: request){
            return AFDataResponse.init(request: request, response: cachedReponse.response as? HTTPURLResponse, data: cachedReponse.data, metrics: nil, serializationDuration: 1, result:  Result.success(try! DictResponseSerializer().serialize(request: nil, response: nil, data: cachedReponse.data, error: nil)))
        }
        return nil
    }
}

extension DataResponse {
    
    /// 保存结果
    ///
    /// - Parameter router: 请求路由
    func saveCache(router: Routerable) {
        if router.useCache, let res = self.response, let data = self.data, let request = self.request, request.httpMethod?.lowercased() == "get" {// 使用cache的请求才需要缓存
            if self.result.isSuccess {
                HttpManager.shared.urlCache.storeCachedResponse(CachedURLResponse.init(response: res, data: data), for: request)
            }else{
                HttpManager.shared.urlCache.removeCachedResponse(for: request)
            }
        }
    }
    private func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data // fallback to original data if it can't be serialized.
        }
    }
}


extension Result {
    var isSuccess: Bool {
        switch self {
        case .success(_):
            return true
        default:
            return false
        }
    }
    
}
