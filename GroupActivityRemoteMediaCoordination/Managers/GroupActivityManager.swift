//
//  GroupActivityManager.swift
//  GroupActivityRemoteMediaCoordination
//
//  Created by Itsuki on 2025/11/02.
//

import GroupActivities
import SwiftUI
import Combine
import AVKit

@Observable
class GroupActivityManager {
    private(set) var selectedVideo: Video? {
        didSet {
            if let video = self.selectedVideo, let url = video.url  {
                let playerItem = AVPlayerItem(url: url)
                self.player.replaceCurrentItem(with: playerItem)
            } else {
                self.player.replaceCurrentItem(with: nil)
            }
        }
    }
    
    private(set) var player: AVPlayer
    
    
    // GroupSession is ObservableObject instead of Observable
    // We can either use it directly in a view with ObservedObject,
    // or we need to sink properties by ourselves, as what we had with state in GroupActivityManager.setupGroupSessionTask
    private(set) var groupSession: GroupSession<WatchVideoActivity>? {
        didSet {
            // session terminates.
            guard let session = self.groupSession else {
                player.pause()
                participants.removeAll()
                return
            }
            
            // Coordinate playback with the active session.
            //
            // In order for the coordination to success and videos are synchronized between multiple devices, the AVPlayer has to be playing the same item (URL)
            //
            // If we need to coordinate medias rendered using AVSampleBufferDisplayLayer and AVSampleBufferAudioRenderer, we should use AVDelegatingPlaybackCoordinator instead.
            player.playbackCoordinator.coordinateWithSession(session)
        }
    }
    
    private(set) var participants: Set<Participant> = Set()
    
    @ObservationIgnored
    private var groupSessionTask: Task<Void, Error>?
    
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()

    
    init() {
        self.player = AVPlayer()
        
        self.setupGroupSessionTask()
        // set up audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch(let error) {
            print(error)
        }
    }
    
    deinit {
        self.groupSessionTask?.cancel()
        self.groupSessionTask = nil
    }
    
    
    func playVideo(_ video: Video) async throws {
        guard video != self.selectedVideo else { return }
        
        // If there's an active session, create an activity
        if let groupSession = groupSession {
            if groupSession.activity.video != video {
                groupSession.activity = WatchVideoActivity(video: video)
            }
            
        } else {

            let activity = WatchVideoActivity(video: video)
            
            let preparationResult = await activity.prepareForActivation()
            
            switch preparationResult {
               
            // User disabled the automatic sharing of activities, or prefers to perform the activity locally.
            //
            // activity.prepareForActivation will automatically enter this state without prompting the user if there is no FaceTime session activated, or the app is being ran on a simulator
            case .activationDisabled:
                self.selectedVideo = video
             
                
            // User wants to share the activity with the group.
            case .activationPreferred:
                // If a FaceTime call is active, this method configures a session.
                // The system also invites other participants to join the activity.
                // If a session will be delivered to your app this function returns true, otherwise it returns false.
                // A case where this function could return false is when a session is created and handed off to an Apple TV.
                // If a call isn’t active or a session wasn’t created, this method throws an error
                let _ = try await activity.activate()
              
            // User canceled the activation request.
            case .cancelled:
                break
                
            @unknown default:
                break
            }
        }

    }
    
    private func setupGroupSessionTask() {
        self.groupSessionTask = Task {
            for await groupSession in WatchVideoActivity.sessions() {
                // Set the app's active group session.
                self.groupSession = groupSession

                self.clearCancellables()
                
                groupSession.$state.sink { [weak self] state in
                    guard let self else { return }
                    switch state {
                        
                    // A state that indicates the session is no longer valid and can’t be used for shared activities.
                    //
                    // When a participant leaves an activity, the system moves their session to the GroupSession.State.invalidated(reason:) state and stops the flow of information between their device and the rest of the group.
                    // When the session moves to this state, it’s safe to discard the session object itself and perform any activity-related cleanup.
                    case .invalidated(let error):
                        print("session invalidated with error: \(error)")
                        self.groupSession = nil
                        self.clearCancellables()
                    
                    // An active state that indicates the session allows data synchronization between devices.
                    //
                    // setting self.groupSession = groupSession here will not work and coordination will fail
                    case .joined:
                        print("joined session")
                    
                    // An idle state that indicates the session is waiting for the app to join the activity.
                    case .waiting:
                        print("waiting for joining")
                    
                    @unknown default:
                        print("unknown state: ", state)
                    }
                    
                }.store(in: &cancellables)
                
                // Observe when the local user or a remote participant starts an activity.
                groupSession.$activity.sink { [weak self] activity in
                    guard let self else { return }
                    self.selectedVideo = activity.video
                }.store(in: &cancellables)
                
                
                groupSession.$activeParticipants.sink { [weak self] participants in
                    guard let self else { return }
                    self.participants = participants
                }.store(in: &cancellables)


                // Join the session to participate in playback coordination.
                groupSession.join()
                
            }
        }

    }
    
    private func clearCancellables() {
        self.cancellables.forEach({ cancellable in
            cancellable.cancel()
        })
        cancellables.removeAll()
    }
    
}
