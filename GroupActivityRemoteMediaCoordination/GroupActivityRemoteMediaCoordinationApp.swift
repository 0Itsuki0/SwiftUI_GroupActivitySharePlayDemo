//
//  GroupActivityRemoteMediaCoordinationApp.swift
//  GroupActivityRemoteMediaCoordination
//
//  Created by Itsuki on 2025/11/01.
//

import SwiftUI

@main
struct GroupActivityRemoteMediaCoordinationApp: App {
    @State private var manager = GroupActivityManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(manager)
        }
    }
}
