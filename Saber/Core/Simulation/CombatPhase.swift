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
    case engagement(waveIndex: Int)
    case results
}

struct CombatContext {
    var phase: CombatPhase = .idle
    var score: Int = 0
    var combo: Int = 0
}

protocol CombatSystem {
    mutating func update(with input: PlayerInputState, deltaTime: TimeInterval) -> CombatContext
}

struct DefaultCombatSystem: CombatSystem {
    private(set) var context = CombatContext()

    mutating func update(with input: PlayerInputState, deltaTime: TimeInterval) -> CombatContext {
        switch context.phase {
        case .idle:
            context.phase = .briefing
        case .briefing:
            if input.gesture != .idle {
                context.phase = .engagement(waveIndex: 0)
            }
        case .engagement:
            context.combo = max(0, context.combo + (input.primaryButtonPressed ? 1 : -1))
            if context.combo > 10 {
                context.phase = .results
            }
        case .results:
            context.score += context.combo * 100
        }
        return context
    }
}
