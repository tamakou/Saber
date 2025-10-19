//
//  AppState.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import SwiftUI
import Observation

@Observable
final class AppState {
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    enum InputPipelineStatus: Equatable {
        case stopped
        case starting
        case running
        case failed
    }

    let immersiveSpaceID = "BattleImmersiveSpace"
    var immersiveSpaceState: ImmersiveSpaceState = .closed
    var activeCombatPhase: CombatPhase = .idle
    var inputPipelineStatus: InputPipelineStatus = .stopped

    func markImmersiveTransition(isOpen: Bool) {
        immersiveSpaceState = isOpen ? .open : .closed
    }

    func markTransitionInProgress() {
        immersiveSpaceState = .inTransition
    }
}
