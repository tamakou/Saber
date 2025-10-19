//
//  SaberApp.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import SwiftUI

@main
struct SaberApp: App {

    @State private var appState = AppState()
    @State private var rootCoordinator = RootCoordinator()

    var body: some Scene {
        WindowGroup {
            RootContentView()
                .environment(appState)
                .environment(rootCoordinator)
        }
        .windowStyle(.volumetric)

        ImmersiveSpace(id: appState.immersiveSpaceID) {
            ImmersiveBattleView()
                .environment(appState)
                .environment(rootCoordinator)
                .task {
                    appState.inputPipelineStatus = .starting
                    let started = await rootCoordinator.startInputPipeline()
                    appState.inputPipelineStatus = started ? .running : .failed
                }
                .onAppear {
                    appState.markImmersiveTransition(isOpen: true)
                }
                .onDisappear {
                    appState.markImmersiveTransition(isOpen: false)
                    rootCoordinator.stopInputPipeline()
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
