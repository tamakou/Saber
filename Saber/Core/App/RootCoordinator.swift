//
//  RootCoordinator.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import Foundation
import Observation

@Observable
@MainActor
final class RootCoordinator {

    private let inputGateway: any InputGateway = HandTrackingInputGateway()

    func startInputPipeline() async -> Bool {
        await inputGateway.start()
    }

    func stopInputPipeline() {
        inputGateway.stop()
    }

    func latestInputState() -> PlayerInputState {
        inputGateway.latestState()
    }
}
