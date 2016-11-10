//
//  VideoListModel.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/27.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import Foundation

class VideoModel: Mappable {
    
    var cover: String?
    var title: String?
    var description: String?
    var mp4_url: String?
    var m3u8_url: String?
    var alias: String?
    var tname: String?
    
    required init?(map: Map) {
        
    }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        
        cover <- map["cover"]
        title <- map["title"]
        description <- map["description"]
        mp4_url <- map["mp4_url"]
        m3u8_url <- map["m3u8_url"]
        alias <- map["videoTopic.alias"]
        tname <- map["videoTopic.tname"]
    }
}

class VideoListModel: Mappable {

    var videoList: [VideoModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        videoList <- map["VAP4BFR16"]
    }
}
