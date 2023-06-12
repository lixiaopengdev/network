//
//  Network+Combine.swift
//  CSMeModule
//
//  Created by 于冬冬 on 2023/5/23.
//

import Moya
import Combine
import ObjectMapper

public extension Network {
    
   static func requestPublisher(_ target: TargetType, callbackQueue: DispatchQueue? = nil) -> AnyPublisher<Response, MoyaError> {
        
       return getPrivode(target).requestPublisher(MultiTarget(target), callbackQueue: callbackQueue)
    }
    
}

public extension AnyPublisher where Output == Response, Failure == MoyaError {
    
    func mapModel<T: Mappable>(_ model: T.Type) -> AnyPublisher<T, NetworkError> {
        return unwrapThrowable { data in
            if let model = Mapper<T>().map(JSONObject: data) {
                return model
            }
            throw NetworkError.undefined(-1, "map error")
        }
    }
    
    func mapModels<T: Mappable>(_ model: T.Type) -> AnyPublisher<[T], NetworkError> {
        return unwrapThrowable { data in
            if let models = Mapper<T>().mapArray(JSONObject: data) {
                return models
            }
            throw NetworkError.undefined(-1, "map error")
        }
    }
    
    func mapVoid() -> AnyPublisher<Void, NetworkError> {
        return unwrapThrowable { data in
            return ()
        }
    }
    
    func mapType<T>(_ type: T.Type) -> AnyPublisher<T, NetworkError> {
        return unwrapThrowable { data in
            if let value = data as? T {
                return value
            }
            throw NetworkError.undefined(-1, "map error")
        }
    }
    
    private func unwrapThrowable<T>(throwable: @escaping (Any) throws -> T) -> AnyPublisher<T, NetworkError> {
        self.tryMap { res in
            let data = try Network.transform(result: .success(res)).get()
            return try throwable(data)
        }.mapError { error in
            if let moyaError = error as? MoyaError {
                return NetworkError.moya(moyaError)
            } else if let networkError = error as? NetworkError  {
                return networkError
            } else {
                return .system(error)
            }
        }.eraseToAnyPublisher()
    }

}

