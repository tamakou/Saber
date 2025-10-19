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

    private(set) var inputGateway: any InputGateway = HandTrackingInputGateway()

    func startInputPipeline() async -> Bool {
        await inputGateway.start()
    }

    func stopInputPipeline() {
        inputGateway.stop()
    }

    func swapToPSVR2IfAvailable() {
        if SenseControllerInputGateway.isControllerAvailable {
            inputGateway.stop()
            inputGateway = SenseControllerInputGateway()
            Task { await inputGateway.start() }
        } else {
            useHandTracking()
        }
    }

    func useHandTracking() {
        inputGateway.stop()
        inputGateway = HandTrackingInputGateway()
        Task { await inputGateway.start() }
    }
}
