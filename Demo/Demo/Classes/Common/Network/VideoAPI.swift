//
//  VideoAPI.swift
//  Demo
//
//  Created by QuintGao on 2024/8/22.
//

import RxNetworks

enum VideoAPI {
    case getVideoList(String, Int)
}

extension VideoAPI: NetworkAPI {
    var ip: APIHost {
        "https://haokan.baidu.com"
    }
    
    var method: APIMethod {
        .get
    }
    
    var path: String {
        switch self {
        case .getVideoList: return "haokan/ui-web/video/rec"
        }
    }
    
    var parameters: APIParameters? {
        var params = Parameters()
        switch self {
        case .getVideoList(let tab, let num):
            params["act"] = "pcFeed"
            params["pd"] = "pc"
            params["tab"] = tab
            params["num"] = num
        }
        return params
    }
}
