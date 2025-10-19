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

    private let saberRoot = Entity()
    private let bladeEntity: ModelEntity
    private let hiltEntity: ModelEntity

    private let bladeLength: Float = 1.0
    private let bladeRadius: Float = 0.015
    private let hiltLength: Float = 0.18
    private let hiltRadius: Float = 0.025

    private var lastHitTimestamp: TimeInterval = 0

    init() {
        saberRoot.name = "PlayerSaberRoot"

        // Hilt
        let hiltMesh = MeshResource.generateCylinder(height: hiltLength, radius: hiltRadius)
        let hiltColor = UIColor(white: 0.2, alpha: 1.0)
        var hiltMaterial = SimpleMaterial(color: hiltColor, roughness: 0.3, isMetallic: true)
        
        hiltEntity = ModelEntity(mesh: hiltMesh, materials: [hiltMaterial])
        hiltEntity.name = "PlayerSaberHilt"
        hiltEntity.position = [0, hiltLength / 2, 0]

        // Blade
        let bladeMesh = MeshResource.generateBox(size: [bladeRadius * 2, bladeLength, bladeRadius * 2])
        let emissiveColor = UIColor(red: 0.35, green: 0.9, blue: 1.0, alpha: 1.0)
        var bladeMaterial = SimpleMaterial(color: emissiveColor.withAlphaComponent(0.9), roughness: 0.05, isMetallic: false)
        bladeMaterial.emissiveColor = .init(tint: emissiveColor, intensity: 4.0)
        bladeEntity = ModelEntity(mesh: bladeMesh, materials: [bladeMaterial])
        bladeEntity.name = "PlayerSaberBlade"
        bladeEntity.position = [0, hiltLength + bladeLength / 2, 0]

        let collisionShape = ShapeResource.generateBox(size: [bladeRadius * 2, bladeLength, bladeRadius * 2])
        bladeEntity.components.set(CollisionComponent(shapes: [collisionShape], mode: .default, filter: CollisionFilter(group: .playerWeapons, mask: [.enemyBody])))
        bladeEntity.components.set(PhysicsBodyComponent(mode: .kinematic))

        saberRoot.addChild(hiltEntity)
        saberRoot.addChild(bladeEntity)
    }

    func attach(to parent: Entity) {
        guard saberRoot.parent == nil else { return }
        parent.addChild(saberRoot)
    }

    func update(with input: PlayerInputState) {
        var handTransform = Transform(matrix: input.pose)
        // Offset so the hilt base sits at the user's palm
        let gripOffset = SIMD3<Float>(0, -hiltLength / 2, 0)
        handTransform.translation += handTransform.rotation.act(gripOffset)
        saberRoot.transform = handTransform
    }

    func impactStrengthIfNeeded(with enemy: EnemyEntity, input: PlayerInputState, time: TimeInterval) -> Float? {
        let tipWorld = tipWorldPosition()
        let distance = simd_length(tipWorld - enemy.coreWorldPosition())
        guard distance < 0.25 else { return nil }
        guard (time - lastHitTimestamp) > 0.25 else { return nil }
        let velocityMagnitude = simd_length(input.linearVelocity)
        lastHitTimestamp = time
        return max(velocityMagnitude, 0.5)
    }

    func resetCooldown() {
        lastHitTimestamp = 0
    }

    private func tipWorldPosition() -> SIMD3<Float> {
        let localTip = SIMD3<Float>(0, hiltLength + bladeLength, 0)
        return saberRoot.convert(position: localTip, to: nil)
    }
}
