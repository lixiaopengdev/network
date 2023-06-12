//
//  TestModel.swift
//  CSNetwork_Example
//
//  Created by 于冬冬 on 2023/1/28.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import ObjectMapper

struct Account : Mappable {
    var name: String?
    var id: Int?
    
    init?(map: ObjectMapper.Map) {
        
    }
    
    mutating func mapping(map: ObjectMapper.Map) {
        name   <- map["name"]
        id  <- map["id"]
    }
    
}
