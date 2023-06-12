//
//  Network+RX.swift
//  CSNetwork
//
//  Created by 于冬冬 on 2023/4/4.
//

import Moya
import ObjectMapper
import Combine
import RxSwift


extension Network: ReactiveCompatible {}

public extension Reactive where Base: Network {
    static func request(_ target: TargetType) -> Single<Response> {
        return Base.getPrivode(target)
            .rx
            .request(MultiTarget(target))
    }
}
    


public extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    func mapModel<T: Mappable>(_ model: T.Type) -> Single<T> {
        flatMap { res in
            let data = try Network.transform(result: .success(res)).get()
            if let model = Mapper<T>().map(JSONObject: data) {
                return .just(model)
            }
            throw NetworkError.undefined(-1, "map error")
        }
    }
    
    func mapModels<T: Mappable>(_ model: T.Type) -> Single<[T]> {
        flatMap { res in
            let data = try Network.transform(result: .success(res)).get()
            if let models = Mapper<T>().mapArray(JSONObject: data) {
                return .just(models)
            }
            throw NetworkError.undefined(-1, "map error")
        }
    }
}
