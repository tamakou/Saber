//
//  HandTrackingInputGateway.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import Foundation
import ARKit
import simd

@MainActor
final class HandTrackingInputGateway: InputGateway {

    private var latest = PlayerInputState()
    private let session = ARKitSession()
    private let handProvider = HandTrackingProvider()
    private var updateTask: Task<Void, Never>?
    private var lastPose: simd_float4x4?
    private var lastTimestamp: Date?

    func start() async -> Bool {
        guard HandTrackingProvider.isSupported else { return false }
        stop()
        do {
            try await session.run([handProvider])
        } catch {
            return false
        }

        updateTask = Task { [weak self] in
            guard let self else { return }
            for await update in handProvider.anchorUpdates {
                let anchor = update.anchor
                self.consume(anchor: anchor)
            }
        }
        return true
    }

    func stop() {
        updateTask?.cancel()
        updateTask = nil
        session.stop()
        latest = PlayerInputState()
        lastPose = nil
        lastTimestamp = nil
    }

    func latestState() -> PlayerInputState {
        latest
    }

    private func consume(anchor: HandAnchor) {
        let now = Date()
        var state = PlayerInputState()
        let pose = anchor.originFromAnchorTransform
        state.pose = pose
        state.timestamp = now

        if let previousPose = lastPose, let previousTimestamp = lastTimestamp {
            let dt = max(now.timeIntervalSince(previousTimestamp), 0.016)
            let previousPosition = position(from: previousPose)
            let currentPosition = position(from: pose)
            let velocity = (currentPosition - previousPosition) / Float(dt)
            state.linearVelocity = velocity
        }

        let speed = simd_length(state.linearVelocity)
        if speed > 1.5 {
            state.gesture = .slash(direction: simd_normalize(state.linearVelocity))
        } else if speed < 0.2 {
            state.gesture = .guardPose
        }

        state.isPinching = isPinchGesture(anchor: anchor)

        latest = state
        lastPose = pose
        lastTimestamp = now
    }

    private func position(from matrix: simd_float4x4) -> simd_float3 {
        let column = matrix.columns.3
        return [column.x, column.y, column.z]
    }

    private func isPinchGesture(anchor: HandAnchor) -> Bool {
        guard let skeleton = anchor.handSkeleton,
              let thumb = skeleton.joint(.thumbTip)?.transform,
              let index = skeleton.joint(.indexTip)?.transform else {
            return false
        }
        let thumbPosition = simd_float3(thumb.columns.3.x, thumb.columns.3.y, thumb.columns.3.z)
        let indexPosition = simd_float3(index.columns.3.x, index.columns.3.y, index.columns.3.z)
        let distance = simd_length(indexPosition - thumbPosition)
        return distance < 0.035
    }
}
