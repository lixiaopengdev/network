//
//  NetworkError.swift
//  comesocial
//
//  Created by 于冬冬 on 2022/11/29.
//

import Moya

public enum ServiceError: Int {
//    case parameter = -10001
//    case tokenInvalid = -10002
//    case dataOutrange = -10003
//    case objectInvalid = -10004
//    case noPermission = -10005
//    case rejected = -10006
    case unLogin = 403
}

public enum NetworkError: Error {
    case moya(MoyaError)
    case server(ServiceError, String)
    case undefined(Int, String)
    case system(Error)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .moya(let moyaError):
            return moyaError.errorDescription
        case .server(let status, let message):
            return "status: \(status), message: \(message)"
        case .system(let error):
            return error.localizedDescription
        case .undefined(let status, let message):
            return "status: \(status), message: \(message)"
        }
    }
    
    public var errorTips: String? {
        switch self {
        case .moya(let moyaError):
            return moyaError.errorDescription
        case .server(_, let message):
            return "\(message)"
        case .system(let error):
            return error.localizedDescription
        case .undefined(_, let message):
            return "\(message)"
        }
    }
    
    
    
}
