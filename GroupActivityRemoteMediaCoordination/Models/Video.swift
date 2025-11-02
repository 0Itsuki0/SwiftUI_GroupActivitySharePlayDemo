//
//  Video.swift
//  GroupActivityRemoteMediaCoordination
//
//  Created by Itsuki on 2025/11/02.
//


import Foundation

struct Video: Codable, Identifiable, Hashable {

    var id: UUID = UUID()

    var title: String
    
    // The url here cannot be a bundle url for example.
    // 1. Bundle URL is different on each device
    // 2. If we make it a calculate property, then the playerItem URL will be different and the playback coordination will fail.
    var url: URL?
}

extension Video {
    static let availableVideos: [Video] = [
        Video(title: "Customize your app for Assistive Access", url: URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2025/238/4/a553c517-f6ca-46e7-b339-36e971996e78/cmaf.m3u8?45399")),

        Video(title: "What’s new in visionOS 26", url: URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2025/317/4/4700af86-65f4-429a-b0a7-7dd18247c03d/cmaf.m3u8?52968")),
        
        Video(title: "What’s new in AdAttributionKit", url: URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2025/221/4/09c47047-90c9-48df-9ed1-f6d24303043e/cmaf.m3u8?40422")),
        
    ]
}
