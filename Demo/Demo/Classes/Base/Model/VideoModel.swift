//
//  VideoModel.swift
//  Demo
//
//  Created by QuintGao on 2024/8/22.
//

import UIKit
import HandyJSON

struct VideoData: HandyJSON {
    var response: VideoModel!
}

struct VideoModel: HandyJSON {
    var videos: [VideoInfo]!
}

struct VideoInfo: HandyJSON {
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
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.video_id <-- "id"
    }
}
