//
//  ContentView.swift
//  GroupActivityRemoteMediaCoordination
//
//  Created by Itsuki on 2025/11/01.
//

import SwiftUI
import GroupActivities
import AVKit
import Combine

struct ContentView: View {
    @Environment(GroupActivityManager.self) private var manager
    
    private let videos = Video.availableVideos
    var body: some View {
        NavigationStack {
            VStack(spacing: 36) {
                VStack(spacing: 8) {
                    Text("WWDC Videos")
                        .font(.headline)
                    ForEach(videos) { video in
                        Button(action: {
                            Task {
                                do {
                                    try await manager.playVideo(video)
                                } catch (let error) {
                                    print(error)
                                }
                            }
                        }, label: {
                            Text(video.title)
                        })
                    }
                }
                
                HStack(spacing: 24) {
                    if let groupSession = manager.groupSession {
                        Text("(Sharing With Group)")
                            .foregroundStyle(.secondary)

                        
                        HStack {
                            Button(action: {
                                groupSession.leave()
                            }, label: {
                                Text("Leave")
                            })
                            
                            Button(action: {
                                groupSession.end()
                            }, label: {
                                Text("End")
                            })

                        }
                    } else {
                        Text("(Local)")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                VideoPlayer()
                    .environment(self.manager)
                    .containerRelativeFrame(.vertical, count: 3, spacing: 16)
                    .overlay(content: {
                        if self.manager.selectedVideo == nil {
                            ContentUnavailableView("Select A Video!", systemImage: "rectangle.slash")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.gray.opacity(0.2))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    })
                    .disabled(self.manager.selectedVideo == nil)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

            }
            .padding()
            .padding(.top, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.yellow.opacity(0.1))
            .navigationTitle("Group Activity Demo")

        }
    }
}


#Preview {
    ContentView()
        .environment(GroupActivityManager())
}
