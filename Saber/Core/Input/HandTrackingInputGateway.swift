//
//  HandTrackingInputGateway.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import RealityKit

@MainActor
final class HandTrackingInputGateway: InputGateway {

    private var latest = PlayerInputState()

    func start() async -> Bool {
        latest = PlayerInputState()
        // TODO: visionOS 26 RealityKit.Input pipeline を構築し、HandTrackingSampleStream から PlayerInputState を更新する。
        return true
    }

    func stop() {
        latest = PlayerInputState()
    }

    func latestState() -> PlayerInputState {
        latest
    }
}
