//
//  WatchVideoActivity.swift
//  GroupActivityRemoteMediaCoordination
//
//  Created by Itsuki on 2025/11/02.
//

import Foundation
import GroupActivities

struct WatchVideoActivity: GroupActivity {
    
    let video: Video
    
    var metadata: GroupActivityMetadata {
        get async {
            var metadata = GroupActivityMetadata()
            metadata.type = .watchTogether
            metadata.fallbackURL = video.url
            metadata.title = video.title
            return metadata
        }
    }
}
