//
//  MainAPI.swift
//  comesocial
//
//  Created by 于冬冬 on 2022/11/28.
//

import Moya
import CSNetwork

enum TestService {
    case login(name: String)
    case card(name: String)
    case cards
}


extension TestService: TargetType {
    var baseURL: URL {
        return URL(string: "http://192.168.50.193")!
    }
    
    var path: String {
        switch self {
        case .login:
            return "/api/v1/login"
        case .card:
            return "/api/v1/card"
        case .cards:
            return "/api/v1/cards"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .cards:
            return .get
        default:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .login(let name):
            let datas: [MultipartFormData] = [
                MultipartFormData(provider: .data(name.data(using: .utf8)!), name: "name")]
            return .uploadMultipart(datas)
        case .cards:
            return .requestPlain
        case .card(let cardName):
            let datas: [MultipartFormData] = [
                MultipartFormData(provider: .data(cardName.data(using: .utf8)!), name: "name")]
            return .uploadMultipart(datas)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
