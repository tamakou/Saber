//
//  CombatPhase.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import Foundation

enum CombatPhase: Equatable {
    case idle
    case briefing
    case duel
    case victory
    case defeat
}

struct CombatContext: Equatable {
    var phase: CombatPhase = .idle
    var score: Int = 0
    var combo: Int = 0
    var playerHealth: Float = 100
    var enemyHealth: Float = 100
    var elapsedPhaseTime: TimeInterval = 0
    var lastPlayerHitTime: TimeInterval = 0
    var lastEnemyHitTime: TimeInterval = 0
}

enum CombatEvent {
    case playerHitEnemy(strength: Float)
    case enemyHitPlayer(strength: Float)
}

protocol CombatSystem {
    mutating func enqueue(_ event: CombatEvent)
    mutating func update(with input: PlayerInputState, deltaTime: TimeInterval) -> CombatContext
}

struct DefaultCombatSystem: CombatSystem {
    private(set) var context = CombatContext()
    private var events: [CombatEvent] = []

    mutating func enqueue(_ event: CombatEvent) {
        events.append(event)
    }

    mutating func update(with input: PlayerInputState, deltaTime: TimeInterval) -> CombatContext {
        context.elapsedPhaseTime += deltaTime

        if context.phase == .idle && input.gesture != .idle {
            context.phase = .briefing
            context.elapsedPhaseTime = 0
        }

        if context.phase == .briefing && context.elapsedPhaseTime > 2.0 {
            context.phase = .duel
            context.elapsedPhaseTime = 0
        }

        for event in events {
            switch event {
            case .playerHitEnemy(let strength):
                let damage = clamp(strength * 25, min: 5, max: 35)
                context.enemyHealth = max(0, context.enemyHealth - damage)
                context.combo += 1
                context.score += Int(damage * Float(context.combo))
                context.lastPlayerHitTime = context.elapsedPhaseTime
                if context.enemyHealth <= 0 {
                    context.phase = .victory
                }
            case .enemyHitPlayer(let strength):
                let damage = clamp(strength * 18, min: 8, max: 30)
                context.playerHealth = max(0, context.playerHealth - damage)
                context.combo = 0
                context.lastEnemyHitTime = context.elapsedPhaseTime
                if context.playerHealth <= 0 {
                    context.phase = .defeat
                }
            }
        }
        events.removeAll(keepingCapacity: true)

        if context.phase == .duel && context.elapsedPhaseTime > 120 {
            context.phase = context.enemyHealth <= 0 ? .victory : .defeat
        }

        return context
    }
}

private func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
    if value < min { return min }
    if value > max { return max }
    return value
}
