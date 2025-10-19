//
//  BattleCoordinator.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import Foundation
import RealityKit
import simd

struct BattleUpdateResult {
    let context: CombatContext
    let inputLatency: TimeInterval
}

@MainActor
final class BattleCoordinator {

    private let worldAnchor: AnchorEntity
    private let rootEntity = Entity()
    private let saber = SaberEntity()
    private let enemy = EnemyEntity()
    private var combatSystem = DefaultCombatSystem()
    private var simulationTime: TimeInterval = 0
    private var previousPhase: CombatPhase = .idle

    init() {
        worldAnchor = AnchorEntity(world: float4x4(diagonal: SIMD4<Float>(1, 1, 1, 1)))
        rootEntity.name = "BattleRoot"

        let floorMesh = MeshResource.generatePlane(width: 3, depth: 3)
        var floorMaterial = SimpleMaterial()
        floorMaterial.color = .init(tint: .init(red: 0.06, green: 0.06, blue: 0.08, alpha: 0.95))
        floorMaterial.metallic = 0.2
        floorMaterial.roughness = 0.7
        let floor = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
        floor.name = "BattleFloor"
        floor.position = [0, 0, 0]
        rootEntity.addChild(floor)

        saber.attach(to: rootEntity)
        enemy.attach(to: rootEntity)

        worldAnchor.addChild(rootEntity)
    }

    var sceneRoot: Entity {
        worldAnchor
    }

    func update(deltaTime: TimeInterval, input: PlayerInputState) -> BattleUpdateResult {
        simulationTime += deltaTime

        saber.update(with: input)
        if let enemyStrike = enemy.update(deltaTime: deltaTime, playerInput: input) {
            combatSystem.enqueue(.enemyHitPlayer(strength: enemyStrike))
        }

        if let strength = saber.impactStrengthIfNeeded(with: enemy, input: input, time: simulationTime) {
            combatSystem.enqueue(.playerHitEnemy(strength: strength))
        }

        let context = combatSystem.update(with: input, deltaTime: deltaTime)

        if context.phase != previousPhase && (context.phase == .victory || context.phase == .defeat) {
            Task { @MainActor in
                try await Task.sleep(for: .seconds(2))
                resetBattle()
            }
        }
        previousPhase = context.phase

        let latency = Date().timeIntervalSince(input.timestamp)
        return BattleUpdateResult(context: context, inputLatency: latency)
    }

    private func resetBattle() {
        simulationTime = 0
        combatSystem = DefaultCombatSystem()
        enemy.reset()
        saber.resetCooldown()
    }
}
