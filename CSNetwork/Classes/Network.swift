//
//  NetWork.swift
//  comesocial
//
//  Created by 于冬冬 on 2022/12/19.
//

import Moya
import ObjectMapper
import Combine
import RxSwift

public typealias SuccessBlock<T: BaseMappable> = (_ model: T) -> Void
public typealias FailureBlock = (_ error: NetworkError) -> Void
public typealias SuccessListBlock<T: BaseMappable> = (_ models: [T]) -> Void
public typealias CompletionOriBlock = (_ result: Result<Any, NetworkError>) -> Void

private typealias CompletionBlock<T: BaseMappable> = (_ result: Result<T, NetworkError>) -> Void
private typealias CompletionListBlock<T: BaseMappable> = (_ result: Result<[T], NetworkError>) -> Void

public protocol NetworkFullUrl {
    var fullUrl: String? { get }
}

public class Network {
    public static let onNetErrorSubject = PassthroughSubject<NetworkError, Never>()
    
    static let requestTimeoutClosure = { (endpoint:Endpoint, done: @escaping MoyaProvider<MultiTarget>.RequestResultClosure) in
        
        do{
            var request = try endpoint.urlRequest()
            request.timeoutInterval = 50
            done(.success(request))
        }catch{
            return
        }
    }
    
    static let fullEndpointClosure = { (target: TargetType) -> Endpoint in
        if let multi = target as? MultiTarget,
           let fullTarget = multi.target as? NetworkFullUrl,
           let fullUrl = fullTarget.fullUrl {
            return Endpoint(url: fullUrl, sampleResponseClosure: {.networkResponse(200, Data())}, method: target.method, task: target.task, httpHeaderFields: target.headers)
        }
        return Endpoint(
            url: URL(target: target).absoluteString,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }
    
    static let provider = MoyaProvider<MultiTarget>(requestClosure: requestTimeoutClosure)
    static let immediateProvider = MoyaProvider<MultiTarget>.init(requestClosure: requestTimeoutClosure,stubClosure: MoyaProvider.immediatelyStub)
    static let fullProvider = MoyaProvider<MultiTarget>(endpointClosure: fullEndpointClosure)

    static func getPrivode(_ target: TargetType) -> MoyaProvider<MultiTarget>{
        if let target = target as? NetworkFullUrl,
            target.fullUrl != nil {

            return fullProvider
        }
        if target.sampleData.count > 0 {
            return immediateProvider
        } else {
            return provider
        }
    }
    // MARK: -- ori
    @discardableResult
    public static func oriRequest(_ target: TargetType,
                                  callbackQueue: DispatchQueue? = .none,
                                  progress: ProgressBlock? = .none,
                                  completion: CompletionOriBlock? = .none) -> Moya.Cancellable {
        return getPrivode(target).request(MultiTarget(target), callbackQueue: callbackQueue, progress: progress) { result in
            let newResult = transform(result: result)
            handleError(newResult)
            completion?(newResult)
        }
    }
    
    static func handleError(_ result: Result<Any, NetworkError>) {
        if case let .failure(error) = result {
            onNetErrorSubject.send(error)
        }
    }
    
    @discardableResult
    public static func request(_ target: TargetType ) -> Moya.Cancellable {
        return oriRequest(target)
    }
    
    
    // MARK: -- generic
    @discardableResult
    public static func request<T: BaseMappable>(_ target: TargetType,
                                                callbackQueue: DispatchQueue? = .none,
                                                progress: ProgressBlock? = .none,
                                                success: @escaping SuccessBlock<T>,
                                                failure: FailureBlock? = .none) -> Moya.Cancellable {
        return lightRequest(target, callbackQueue: callbackQueue, progress: progress) { (result: Result<T, NetworkError>) in
            switch result {
            case .success(let model):
                success(model)
            case .failure(let error):
                failure?(error)
            }
        }
    }
    
    @discardableResult
    public static func request<T: BaseMappable>(_ target: TargetType,
                                                callbackQueue: DispatchQueue? = .none,
                                                progress: ProgressBlock? = .none,
                                                success: @escaping SuccessListBlock<T>,
                                                failure: FailureBlock? = .none) -> Moya.Cancellable {
        return lightRequest(target, callbackQueue: callbackQueue, progress: progress) { (result: Result<[T], NetworkError>) in
            switch result {
            case .success(let model):
                success(model)
            case .failure(let error):
                failure?(error)
            }
        }
    }
    
    @discardableResult
    public static func request<T: BaseMappable>(_ target: TargetType,
                                                type: T.Type,
                                                callbackQueue: DispatchQueue? = .none,
                                                progress: ProgressBlock? = .none,
                                                success: @escaping SuccessBlock<T>,
                                                failure: FailureBlock? = .none) -> Moya.Cancellable {
        return lightRequest(target, callbackQueue: callbackQueue, progress: progress) { (result: Result<T, NetworkError>) in
            switch result {
            case .success(let model):
                success(model)
            case .failure(let error):
                failure?(error)
            }
        }
    }
    
    @discardableResult
    public static func request<T: BaseMappable>(_ target: TargetType,
                                                types: T.Type,
                                                callbackQueue: DispatchQueue? = .none,
                                                progress: ProgressBlock? = .none,
                                                success: @escaping SuccessListBlock<T>,
                                                failure: FailureBlock? = .none) -> Moya.Cancellable {
        return lightRequest(target, callbackQueue: callbackQueue, progress: progress) { (result: Result<[T], NetworkError>) in
            switch result {
            case .success(let model):
                success(model)
            case .failure(let error):
                failure?(error)
            }
        }
    }

    
    
    // MARK: -- private
    private static func lightRequest<T: BaseMappable>(_ target: TargetType,
                                                      callbackQueue: DispatchQueue? = .none,
                                                      progress: ProgressBlock? = .none,
                                                      completion: CompletionBlock<T>? = .none) -> Moya.Cancellable {
        return oriRequest(target, callbackQueue: callbackQueue, progress: progress) { result in
            let resultModel:Result<T, NetworkError> = result.flatMap({ data in
                if let model = Mapper<T>().map(JSONObject: data) {
                    return .success(model)
                }
                return .failure(.undefined(-1, "map error"))
            })
            completion?(resultModel)
        }
    }
    
    private static func lightRequest<T: BaseMappable>(_ target: TargetType,
                                                      callbackQueue: DispatchQueue? = .none,
                                                      progress: ProgressBlock? = .none,
                                                      completion: CompletionListBlock<T>? = .none) -> Moya.Cancellable {
        return oriRequest(target, callbackQueue: callbackQueue, progress: progress) { result in
            let resultModel:Result<[T], NetworkError> = result.flatMap({ data in
                if let models = Mapper<T>().mapArray(JSONObject: data) {
                    return .success(models)
                }
                return .failure(.undefined(-1, "map error"))
            })
            completion?(resultModel)
        }
    }
    
    static func transform(result: Result<Moya.Response, MoyaError>) -> Result<Any, NetworkError> {
        switch result {
        case .success(let res):
            do {
                let resObject = try res.mapJSON() as? [String: Any]
                if let status = resObject?["status"] as? Int,
                   status != 200 {

                    let errMsg = resObject?["err_msg"] as? String ?? "none"
                    if let errCodeType = ServiceError(rawValue: status) {
                        return .failure(.server(errCodeType, errMsg))
                    } else {
                        return .failure(.undefined(status, errMsg))
                    }
                    
                } else {
                    if let data = resObject?["data"] {
                        return .success(data)
                    } else {
                        return .failure(.undefined(-1, "map error"))
                    }
                }
            } catch let kError {
                if let kError = kError as? MoyaError {
                    return .failure(.moya(kError))
                } else {
                    return .failure(.system(kError))
                }
            }
        case .failure(let error):
            return .failure(.moya(error))
        }
    }
    
}

