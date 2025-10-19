//
//  PSVR2SenseInputGateway.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import GameController
import simd

@MainActor
final class PSVR2SenseInputGateway: InputGateway {

    static var isControllerAvailable: Bool {
        GCController.controllers().contains { $0.vendorName == "PS VR2 Sense" }
    }

    private var latest = PlayerInputState()
    private var controllerObservation: NSObjectProtocol?

    func start() async -> Bool {
        latest = PlayerInputState()
        registerNotifications()
        return true
    }

    func stop() {
        if let token = controllerObservation {
            NotificationCenter.default.removeObserver(token)
        }
        controllerObservation = nil
        GCController.stopWirelessControllerDiscovery()
        latest = PlayerInputState()
    }

    func latestState() -> PlayerInputState {
        latest
    }

    private func registerNotifications() {
        controllerObservation = NotificationCenter.default.addObserver(forName: .GCControllerDidBecomeCurrent, object: nil, queue: .main) { [weak self] notification in
            guard let sense = notification.object as? GCController else { return }
            self?.bindInputs(for: sense)
        }

        GCController.startWirelessControllerDiscovery {}
        GCController.controllers().forEach(bindInputs(for:))
    }

    private func bindInputs(for controller: GCController) {
        guard controller.vendorName == "PS VR2 Sense" else { return }

        controller.motion?.valueChangedHandler = { [weak self] motion in
            guard let self else { return }
            self.latest.pose = simd_float4x4(attitude: motion)
            self.latest.angularVelocity = simd_float3(Float(motion.rotationRate.x), Float(motion.rotationRate.y), Float(motion.rotationRate.z))
            self.latest.linearVelocity = simd_float3(Float(motion.userAcceleration.x), Float(motion.userAcceleration.y), Float(motion.userAcceleration.z))
        }

        controller.extendedGamepad?.buttonA.valueChangedHandler = { [weak self] _, _, pressed in
            guard let self else { return }
            self.latest.primaryButtonPressed = pressed
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
