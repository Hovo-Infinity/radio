//
//  SongItem.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 8/20/18.
//  Copyright © 2018 Hovhannes Stepanyan. All rights reserved.
//

import Foundation

struct SongItem {
    var id: String
    var name: String
    var listenUrl: String?
    var downloadUrl: String?
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

extension SongItem: Equatable {
    static func ==(lhs: SongItem, rhs: SongItem) -> Bool {
        return lhs.id == rhs.id
    }
}
