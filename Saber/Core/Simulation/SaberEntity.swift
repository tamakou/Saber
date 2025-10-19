//
//  SaberEntity.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import Foundation
import RealityKit
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
    private let restPosition = SIMD3<Float>(0, 0.9, -1.0)
    private let grabDistance: Float = 0.35

    private var lastHitTimestamp: TimeInterval = 0
    private var isHeld = false

    init() {
        saberRoot.name = "PlayerSaberRoot"

        // Hilt
        let hiltMesh = MeshResource.generateCylinder(height: hiltLength, radius: hiltRadius)
        let hiltMaterial = SimpleMaterial(color: .gray, roughness: 0.3, isMetallic: true)
        
        hiltEntity = ModelEntity(mesh: hiltMesh, materials: [hiltMaterial])
        hiltEntity.name = "PlayerSaberHilt"
        hiltEntity.position = [0, hiltLength / 2, 0]

        // Blade
        let bladeMesh = MeshResource.generateBox(size: [bladeRadius * 2, bladeLength, bladeRadius * 2])
        let bladeMaterial = SimpleMaterial(color: .cyan, roughness: 0.05, isMetallic: false)
        bladeEntity = ModelEntity(mesh: bladeMesh, materials: [bladeMaterial])
        bladeEntity.name = "PlayerSaberBlade"
        bladeEntity.position = [0, hiltLength + bladeLength / 2, 0]

        let collisionShape = ShapeResource.generateBox(size: [bladeRadius * 2, bladeLength, bladeRadius * 2])
        bladeEntity.components.set(CollisionComponent(shapes: [collisionShape], mode: .default, filter: CollisionFilter(group: .playerWeapons, mask: [.enemyBody])))
        bladeEntity.components.set(PhysicsBodyComponent(mode: .kinematic))

        saberRoot.addChild(hiltEntity)
        saberRoot.addChild(bladeEntity)
        saberRoot.position = restPosition
    }

    func attach(to parent: Entity) {
        guard saberRoot.parent == nil else { return }
        parent.addChild(saberRoot)
    }

    func update(with input: PlayerInputState) {
        var handTransform = Transform(matrix: input.pose)
        let handPosition = handTransform.translation
        let saberWorldPosition = worldPosition()

        if !isHeld {
            let distance = simd_length(handPosition - saberWorldPosition)
            if distance < grabDistance && input.isGrabbing {
                isHeld = true
            } else {
                return
            }
        } else if !input.isGrabbing {
            resetToRest()
            return
        }

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

    func resetToRest() {
        isHeld = false
        saberRoot.transform = .init(translation: restPosition)
    }

    private func worldPosition() -> SIMD3<Float> {
        saberRoot.convert(position: .zero, to: nil)
    }
}
