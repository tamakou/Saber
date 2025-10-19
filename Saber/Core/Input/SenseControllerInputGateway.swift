//
//  SenseControllerInputGateway.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import Foundation
import GameController
import simd

@MainActor
final class SenseControllerInputGateway: InputGateway {

    static var isControllerAvailable: Bool {
        GCController.controllers().contains { $0.vendorName == "PS VR2 Sense" }
    }

    private var latest = PlayerInputState()
    private var controllerObservers: [NSObjectProtocol] = []

    func start() async -> Bool {
        latest = PlayerInputState()
        registerNotifications()
        return true
    }

    func stop() {
        controllerObservers.forEach(NotificationCenter.default.removeObserver)
        controllerObservers.removeAll()
        GCController.stopWirelessControllerDiscovery()
        latest = PlayerInputState()
    }

    func latestState() -> PlayerInputState {
        latest
    }

    private func registerNotifications() {
        let currentToken = NotificationCenter.default.addObserver(forName: .GCControllerDidBecomeCurrent, object: nil, queue: .main) { [weak self] notification in
            guard let sense = notification.object as? GCController else { return }
            Task { @MainActor in self?.bindInputs(for: sense) }
        }
        controllerObservers.append(currentToken)

        let connectToken = NotificationCenter.default.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { [weak self] notification in
            guard let sense = notification.object as? GCController else { return }
            Task { @MainActor in self?.bindInputs(for: sense) }
        }
        controllerObservers.append(connectToken)

        let disconnectToken = NotificationCenter.default.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.latest = PlayerInputState() }
        }
        controllerObservers.append(disconnectToken)

        GCController.startWirelessControllerDiscovery {}
        GCController.controllers().forEach(bindInputs(for:))
    }

    private func bindInputs(for controller: GCController) {
        guard controller.vendorName == "PS VR2 Sense" else { return }

        controller.motion?.valueChangedHandler = { motion in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.latest.pose = simd_float4x4(attitude: motion)
                self.latest.angularVelocity = simd_float3(Float(motion.rotationRate.x), Float(motion.rotationRate.y), Float(motion.rotationRate.z))
                self.latest.linearVelocity = simd_float3(Float(motion.userAcceleration.x), Float(motion.userAcceleration.y), Float(motion.userAcceleration.z))
                self.latest.timestamp = Date()
            }
        }

        controller.extendedGamepad?.buttonA.valueChangedHandler = { _, _, pressed in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.latest.primaryButtonPressed = pressed
                self.latest.timestamp = Date()
            }
        }
    }
}

private extension simd_float4x4 {
    init(attitude motion: GCMotion) {
        let quaternion = motion.attitude
        let simdQuaternion = simd_quatf(ix: Float(quaternion.x), iy: Float(quaternion.y), iz: Float(quaternion.z), r: Float(quaternion.w))
        self = simd_float4x4(simdQuaternion)
    }
}
