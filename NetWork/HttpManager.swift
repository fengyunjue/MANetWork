//
//  HttpManager.swift
//  KF5SDK_Swift
//
//  Created by admin on 17/1/6.
//  Copyright © 2017年 kf5. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD

// MARK: - HTTP请求管理
public final class HttpManager{
    private init(){}
    // 创建单例
    static let shared = HttpManager()
    // 缓存
    let urlCache = URLCache.init(memoryCapacity: 4*1024*1024, diskCapacity: 20*1024*1024, diskPath: nil)
    
    lazy var alamofireManager: SessionManager = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = SessionManager(configuration: config)
        return session
    }()
}
// MARK: - 基本网络请求
extension HttpManager{
    /// 快捷网络请求
    ///
    /// - Parameters:
    ///   - router: 路由地址
    ///   - queue: 线程
    ///   - completionHandler: 完成的回调,isEnd用于处理带缓存的请求,一般情况会先返回缓存,等请求完成在返回真实数据
    @discardableResult
    public static func requestResult(router: Routerable, queue: DispatchQueue? = DispatchQueue.global(),isShowError: Bool = true, completionHandler: @escaping (Result<JSON>, Bool) -> Void) -> DataRequest{
        return request(router: router, queue: queue, isShowError: isShowError, completionHandler: { (response, isEnd) in
            completionHandler(response.result, isEnd)
        })
    }
    /// 通用网络请求
    ///
    /// - Parameters:
    ///   - router: 路由地址
    ///   - queue: 线程
    ///   - completionHandler: 完成的回调,isEnd用于处理带缓存的请求,一般情况会先返回缓存,等请求完成在返回真实数据
    @discardableResult
    public static func request(router: Routerable, queue: DispatchQueue? = DispatchQueue.global(),isShowError: Bool = true, completionHandler: @escaping (DataResponse<JSON>, Bool) -> Void) -> DataRequest{
        
        let newQueue: DispatchQueue = queue ?? DispatchQueue.global()
        
        let request = shared.alamofireManager.request(router.url, method: router.method, parameters: router.parameters, encoding: URLEncoding.default, headers: router.headerFields)
        
        var isEnd = false
        if router.useCache {// 如果使用cache
            newQueue.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: {
                if isEnd == false, let dataResponse = request.cacheRequest(router: router) {
                    print("*******\(router.url)使用缓存*******")
                    completionHandler(dataResponse, isEnd)
                }
            })
        }
        
        // 将要发送请求
        willSend(request)
        request.responseDict(router: router, queue: newQueue, completionHandler: { response in
            // 保存结果
            response.saveCache(router: router)
            // 请求结束
            isEnd = true
            // 完成请求返回
            completionHandler(response, isEnd)
            // 接收到服务端的结果
            didReceive(response, isShowError: isShowError)
        })
        return request
    }
}
// MARK: - Default处理
extension HttpManager {
    // MARK: - 网络指示器
    private static func NetworkActivityIndicatorVisible(_ isVisible: Bool){
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = isVisible
        }
    }
    fileprivate static func willSend(_ request: DataRequest) {
        NetworkActivityIndicatorVisible(true)
    }
    fileprivate static func didReceive(_ response: DataResponse<JSON>, isShowError: Bool = true){
        NetworkActivityIndicatorVisible(false)
        print(response.debugDescription)
        if case let .failure(error) = response.result, isShowError{
            DispatchQueue.main.async {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
}
