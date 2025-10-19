//
//  InputGateway.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import Foundation
import simd

struct PlayerInputState: Sendable, Equatable {
    var pose: simd_float4x4 = matrix_identity_float4x4
    var linearVelocity: simd_float3 = .zero
    var angularVelocity: simd_float3 = .zero
    var gesture: PlayerGesture = .idle
    var primaryButtonPressed: Bool = false
    var timestamp: Date = .now
    var isGrabbing: Bool = false

    enum PlayerGesture: Equatable {
        case idle
        case slash(direction: simd_float3)
        case guardPose
        case forcePush
    }
}

@MainActor
protocol InputGateway: AnyObject {
    func start() async -> Bool
    func stop()
    func latestState() -> PlayerInputState
}
