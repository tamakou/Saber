//
//  EnemyEntity.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import Foundation
import RealityKit
import UIKit
import simd

@MainActor
final class EnemyEntity {

    enum BehaviorState {
        case idle
        case telegraph
        case strike
        case recover
    }

    private let entity: ModelEntity
    private var state: BehaviorState = .idle
    private var phaseTime: TimeInterval = 0
    private var strikeIssued = false

    init() {
        let mesh = MeshResource.generateSphere(radius: 0.25)
        let material = SimpleMaterial(color: UIColor.systemRed.withAlphaComponent(0.7), roughness: 0.3, isMetallic: false)
        entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "TrainingDroid"
        entity.components.set(PhysicsBodyComponent(mode: .kinematic))
        let collision = CollisionComponent(shapes: [.generateSphere(radius: 0.3)], mode: .default, filter: CollisionFilter(group: .enemyBody, mask: [.playerWeapons]))
        entity.components.set(collision)
        entity.position = [0, 1.2, -1.2]
    }

    func attach(to parent: Entity) {
        guard entity.parent == nil else { return }
        parent.addChild(entity)
    }

    func update(deltaTime: TimeInterval, playerInput: PlayerInputState) -> Float? {
        phaseTime += deltaTime
        switch state {
        case .idle:
            if phaseTime > 2.5 {
                advance(to: .telegraph)
            }
        case .telegraph:
            pulse(scale: 1.1)
            if phaseTime > 1.0 {
                advance(to: .strike)
            }
        case .strike:
            pulse(scale: 1.2)
            if !strikeIssued {
                strikeIssued = true
                return 1.0
            }
            if phaseTime > 0.4 {
                advance(to: .recover)
            }
        case .recover:
            pulse(scale: 0.95)
            if phaseTime > 1.2 {
                advance(to: .idle)
            }
        }
        lookAtPlayer(using: playerInput)
        return nil
    }

    func coreWorldPosition() -> SIMD3<Float> {
        entity.convert(position: .zero, to: nil)
    }

    func reset() {
        advance(to: .idle)
        entity.scale = .one
        strikeIssued = false
        phaseTime = 0
    }

    private func advance(to newState: BehaviorState) {
        state = newState
        phaseTime = 0
        strikeIssued = false
    }

    private func lookAtPlayer(using input: PlayerInputState) {
        let playerPosition = SIMD3<Float>(input.pose.columns.3.x, input.pose.columns.3.y, input.pose.columns.3.z)
        let current = coreWorldPosition()
        let direction = simd_normalize(playerPosition - current)
        var transform = entity.transform
        transform.translation = current
        transform.rotation = simd_quatf(from: [0, 0, -1], to: direction)
        entity.transform = transform
    }

    private func pulse(scale: Float) {
        entity.scale = SIMD3<Float>(repeating: scale)
    }
}
