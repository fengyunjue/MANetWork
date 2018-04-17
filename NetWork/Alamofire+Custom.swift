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

public struct MAError: LocalizedError {
    public var errorDescription: String?
    public var errorCode: Int
    
    init(errorCode: Int, message: String) {
        self.errorCode = errorCode
        self.errorDescription = message
    }
}



// MARK: - Alamofire扩展
extension DataRequest {
    @discardableResult
    public func responseDict(
        router: Routerable, queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<JSON>) -> Void) -> Self{
        
        response(queue: queue, responseSerializer: DataResponseSerializer { _, response, data, error in
            return DataRequest.dealResult(Request.serializeResponseData(response: response, data: data, error: error))
            }, completionHandler:completionHandler)
        return self
    }
    
    class func dealResult(_ data: Result<Data>) -> Result<JSON> {
        var result: Result<JSON>! = nil
        switch  data{
        case .success(let jsonData):
            do {
                let json = try JSON(data: jsonData)
                let errCode = json["error"].intValue
                let message = json["message"].stringValue
                if errCode == 0 {
                    result = Result.success(json)
                }else{
                    let error = MAError.init(errorCode: errCode, message: message)
                    result = Result.failure(error)
                }
            } catch let error{
                result = Result.failure(error)
            }
        case .failure(let error):
            result =  Result.failure(error)
        }
        return result
    }
    
    /// 获取缓存
    ///
    /// - Parameter router: 请求路由
    /// - Returns: 返回结果
    func cacheRequest(router: Routerable) -> DataResponse<JSON>?  {
        if let request = self.request, request.httpMethod?.lowercased() == "get", let cachedReponse = HttpManager.shared.urlCache.cachedResponse(for: request){
            return DataResponse.init(request: request, response: (cachedReponse.response as! HTTPURLResponse), data: cachedReponse.data, result: DataRequest.dealResult(Result.success(cachedReponse.data)))
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
    
    public var debugDescription: String {
        
        var output: [String] = []
        output.append("[Alamofire]")
        // Request
        output.append("[Request]:\(self.request?.description ?? "(invalid request)")")
        if let headers = self.request?.allHTTPHeaderFields {
            output.append("[Headers]:\(headers.description)")
        }
        if let bodyStream = self.request?.httpBodyStream {
            output.append("[BodyStream]:\(bodyStream.description)")
        }
        if let httpMethod = self.request?.httpMethod {
            output.append("[Method]:\(httpMethod)")
        }
        if let body = self.request?.httpBody, let stringOutput = String(data: body, encoding: .utf8) {
            output.append("[Body]:\(stringOutput)")
        }
        output.append("[Data]: \(data?.count ?? 0) bytes")
        output.append("[Time]: \(timeline.requestDuration)")
        if let data = data {
            do {
                output.append("[Result]: \(try JSON.init(data: data))")
            }catch {}
        }else{
            output.append("[Result]: \(result.value.debugDescription)")
        }
        return output.joined(separator: "\n")
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
