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
    @State private var battleCoordinator = BattleCoordinator()
    @State private var lastUpdate = Date()

    var body: some View {
        RealityView { content in
            if content.entities.isEmpty {
                if let immersiveEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                    content.add(immersiveEntity)
                }
            }
            if battleCoordinator.sceneRoot.parent == nil {
                content.add(battleCoordinator.sceneRoot)
            }
        } update: { _ in
            let now = Date()
            let delta = now.timeIntervalSince(lastUpdate)
            lastUpdate = now
            let input = coordinator.latestInputState()
            DispatchQueue.main.async {
                let result = battleCoordinator.update(deltaTime: delta, input: input)
                appState.combatContext = result.context
                appState.activeCombatPhase = result.context.phase
                appState.lastInputLatency = result.inputLatency
                MetricLogger.shared.recordFrame(deltaTime: delta, inputLatency: result.inputLatency, phase: result.context.phase)
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveBattleView()
        .environment(AppState())
        .environment(RootCoordinator())
}
