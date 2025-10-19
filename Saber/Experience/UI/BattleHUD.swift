//
//  BattleHUD.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import SwiftUI

struct BattleHUD: View {

    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(phaseLabel)
                .font(.title3)
                .bold()
            HStack {
                ProgressView(value: Double(appState.combatContext.playerHealth), total: 100)
                    .progressViewStyle(.linear)
                Text("Player HP: \(Int(appState.combatContext.playerHealth))")
                    .font(.caption)
            }
            HStack {
                ProgressView(value: Double(appState.combatContext.enemyHealth), total: 100)
                    .progressViewStyle(.linear)
                Text("Enemy HP: \(Int(appState.combatContext.enemyHealth))")
                    .font(.caption)
            }
            Text("Combo: \(appState.combatContext.combo)   Score: \(appState.combatContext.score)")
                .font(.caption)
            Text("Input Latency: \(String(format: "%.2f", appState.lastInputLatency * 1000)) ms")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var phaseLabel: String {
        switch appState.combatContext.phase {
        case .idle: return "Ready"
        case .briefing: return "Briefing"
        case .duel: return "Duel"
        case .victory: return "Victory"
        case .defeat: return "Defeat"
        }
    }
}

#Preview {
    let appState = AppState()
    appState.combatContext = CombatContext(phase: .duel, score: 1200, combo: 3, playerHealth: 78, enemyHealth: 45, elapsedPhaseTime: 42, lastPlayerHitTime: 41, lastEnemyHitTime: 30)
    appState.lastInputLatency = 0.012
    return BattleHUD()
        .environment(appState)
}
