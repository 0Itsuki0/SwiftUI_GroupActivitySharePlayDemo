//
//  VideoPlayer.swift
//  AirplayPlaybackRoutingDemo
//
//  Created by Itsuki on 2025/11/01.
//


import AVKit
import SwiftUI

// Wrapper around AVPlayerViewController for more control
struct VideoPlayer: UIViewControllerRepresentable {
    @Environment(GroupActivityManager.self) private var manager


    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerController = AVPlayerViewController()
        
        playerController.showsPlaybackControls = true
        playerController.allowsPictureInPicturePlayback = true
        playerController.canStartPictureInPictureAutomaticallyFromInline = true

        playerController.player = manager.player
        
        return playerController
    }
    
    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
        playerController.updatesNowPlayingInfoCenter = true
    }
}
