//
//  ImmersiveBattleView.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveBattleView: View {

    @Environment(AppState.self) private var appState
    @Environment(RootCoordinator.self) private var coordinator
    @State private var combatSystem = DefaultCombatSystem()
    @State private var lastUpdate = Date()

    var body: some View {
        RealityView { content in
            if content.entities.isEmpty {
                if let immersiveEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                    content.add(immersiveEntity)
                }
            }
        } update: { _ in
            let now = Date()
            let delta = now.timeIntervalSince(lastUpdate)
            lastUpdate = now
            let input = coordinator.inputGateway.latestState()
            let context = combatSystem.update(with: input, deltaTime: delta)
            appState.activeCombatPhase = context.phase
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveBattleView()
        .environment(AppState())
        .environment(RootCoordinator())
}
