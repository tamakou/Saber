//
//  SaberEntity.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import Foundation
import RealityKit
import UIKit
import simd

@MainActor
final class SaberEntity {

    private let bladeLength: Float = 1.0
    private let bladeRadius: Float = 0.015
    private let bladeEntity: ModelEntity
    private var lastHitTimestamp: TimeInterval = 0

    init() {
        let mesh = MeshResource.generateBox(size: [bladeRadius * 2, bladeLength, bladeRadius * 2])
        let material = SimpleMaterial(color: UIColor.systemCyan, roughness: 0.1, isMetallic: false)
        bladeEntity = ModelEntity(mesh: mesh, materials: [material])
        bladeEntity.name = "PlayerSaber"
        bladeEntity.components.set(PhysicsBodyComponent(mode: .kinematic))
        let collisionShape = ShapeResource.generateBox(size: [bladeRadius * 2, bladeLength, bladeRadius * 2])
        let collision = CollisionComponent(shapes: [collisionShape], mode: .default, filter: CollisionFilter(group: .playerWeapons, mask: [.enemyBody]))
        bladeEntity.components.set(collision)
    }

    func attach(to parent: Entity) {
        guard bladeEntity.parent == nil else { return }
        parent.addChild(bladeEntity)
    }

    func update(with input: PlayerInputState) {
        let transform = Transform(matrix: input.pose)
        bladeEntity.transform = transform
    }

    func impactStrengthIfNeeded(with enemy: EnemyEntity, input: PlayerInputState, time: TimeInterval) -> Float? {
        let tipWorld = tipWorldPosition()
        let distance = simd_length(tipWorld - enemy.coreWorldPosition())
        guard distance < 0.25 else { return nil }
        guard (time - lastHitTimestamp) > 0.3 else { return nil }
        let velocityMagnitude = simd_length(input.linearVelocity)
        lastHitTimestamp = time
        return max(velocityMagnitude, 0.5)
    }

    func resetCooldown() {
        lastHitTimestamp = 0
    }

    private func tipWorldPosition() -> SIMD3<Float> {
        let localTip = SIMD3<Float>(0, bladeLength / 2, 0)
        return bladeEntity.convert(position: localTip, to: nil)
    }
}
