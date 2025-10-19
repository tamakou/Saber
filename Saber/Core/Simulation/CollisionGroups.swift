//
//  CollisionGroups.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import RealityKit

extension CollisionGroup {
    static let playerWeapons: CollisionGroup = CollisionGroup(rawValue: 1 << 0)
    static let enemyBody: CollisionGroup = CollisionGroup(rawValue: 1 << 1)
}
