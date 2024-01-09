//
//  VideoModel.swift
//  Example
//
//  Created by QuintGao on 2023/9/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import Foundation
import HandyJSON

struct VideoModel: HandyJSON {
    var video_id: String!
    var title: String!
    var poster_small: String!
    var poster_big: String!
    var source_name: String!
    var play_url: String!
    var duration: String!
    var url: String!
    var show_tag: String!
    var publish_time: String!
    var is_pay_column: String!
    var like: String!
    var comment: String!
    var playcnt: String!
    var fmplaycnt: String!
    var fmplaycnt_2: String!
    var outstand_tag: String!
    var previewUrlHttp: String!
    var third_id: String!
    var vip: String!
    var author_avatar: String!
    
    var isLike: Bool = false
}

