//
//  RxManager.swift
//  KF5SDKSwift
//
//  Created by admin on 17/3/10.
//  Copyright © 2017年 kf5. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import Alamofire
import SVProgressHUD

public extension Routerable {
    public var rx_request: Observable<JSON> {
        return HttpManager.rx_requestResult(self)
    }
}

// MARK: - HttpManager的Rx扩展
extension HttpManager {
    /// Rx版本的网络请求
    ///
    /// - Parameter router: 路由地址
    /// - Returns: 回调
    public static func rx_requestResult(_ router: Routerable, isShowError: Bool = true) -> Observable<JSON>{
        return Observable.create({observer -> Disposable in
            let request = HttpManager.requestResult(router: router, completionHandler: { result, isEnd in
                switch result {
                case let .success(value):
                    observer.onNext(value)
                    if isEnd {
                        observer.onCompleted()
                    }
                case let .failure(error):
                    observer.onError(error)
                }
            })
            return Disposables.create {
                request.cancel()
            }
        })
    }
}

// MARK: - 添加新的Observable类型
extension ObservableType {
    /// 显示HUD
    public func showHUD() -> Observable<Self.E> {
        return Observable.create { observer in
            var isEnd = false
            // showHUD
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: {
                if isEnd == false {
                    SVProgressHUD.show()
                }
            })
            
            let end = {
                isEnd = true
                // hideHUD
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
            
            return self.do(onDispose: {
                end()
            }).subscribe({ event in
                end()
                observer.on(event)
            })
        }
    }
    /// 绑定成功的值
    public func bindSuccess(to variable: Variable<E>) -> Disposable {
        return subscribe { event in
            switch event {
            case let .next(element):
                variable.value = element
            case .error(_):
                break
            case .completed:
                break
            }
        }
    }
    
    /// 当next或error时执行
    public func doOnce(on: @escaping ((E?) -> Void)) -> Observable<E> {
        return self.do(onNext: { (element) in
            on(element)
        }, onError: { (_) in
            on(nil)
        })
    }
    /// 便利返回数据
    public static func next(_ element: E) -> Observable<E> {
        return Observable.create({ (observer) -> Disposable in
            observer.onNext(element)
            observer.onCompleted()
            return Disposables.create()
        })
    }
    
    
    /// 网络请求
    public func httpRequest(_ router: Routerable) -> Observable<JSON>{
        return Observable.create({ observer -> Disposable in
            var request: DataRequest? = nil
            let dispose = self.subscribe({ event in
                switch event {
                case .next(_):
                    request = HttpManager.requestResult(router: router, completionHandler: { result, isEnd in
                        switch result {
                        case let .success(value):
                            observer.onNext(value)
                            if isEnd {
                                observer.onCompleted()
                            }
                        case let .failure(error):
                            observer.onError(error)
                        }
                    })
                case let .error(error):
                    observer.onError(error)
                default:
                    break
                }
            })
            return Disposables.create {
                dispose.dispose()
                request?.cancel()
            }
        })
    }
}
