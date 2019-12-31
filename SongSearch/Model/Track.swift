//
//  Track.swift
//  SongSearch
//
//  Created by joonwon lee on 02/04/2019.
//  Copyright © 2019 joonwon.lee. All rights reserved.
//

import UIKit

struct Response: Codable {
    let resultCount: Int
    let results: [Track]
}

struct Track: Codable {
    let title: String
    let artistName: String
    let thumbnail: String
    let previewUrl: String // 뮤직비디오가 실제로 재생될 수 있게 해주는 url
    
    enum CodingKeys: String, CodingKey {
        case title = "trackName"
        case artistName = "artistName"
        case thumbnail = "artworkUrl30"
        case previewUrl = "previewUrl"
    }
}
