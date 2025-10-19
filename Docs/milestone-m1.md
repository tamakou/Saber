# Milestone M1: Foundation Setup

Document date: October 19, 2025  
Target sprint window: Week 0-1 (per requirements roadmap)

## 目的
- visionOS 26 / Swift 6.2 / Xcode 16 開発環境で最小実行プロジェクトを安定化し、後続の戦闘機能を高速実装できる足場を整える。
- AGENTS.md と requirements.md の方針を仕様として明文化し、コード作業開始前に合意する。

## 章構成

### Chapter 1: プロジェクト設定整合
- Bundle identifier、deployment target、architecture (visionOS 26、Arm64) を確認し、Info.plist と build settings に反映する。
- RealityKit、SwiftUI、Metal を有効化し、SceneKit / legacy ARKit 依存を排除する。
- 90 Hz ハンドトラッキングおよび PS VR2 Sense controller を想定した capability フラグ (手入力、アクセサリアクセス) を確認。

### Chapter 2: ディレクトリ & モジュール構成
- `Saber` Swift package/target 内に Core (基盤サービス)、Features (機能別)、Experience (UI/RealityView) のディレクトリを作成。
- RealityKit エンティティ定義は `Core/Simulation`, UI は `Experience/UI`, 入力は `Core/Input` に分類する。
- 自動テストを `SaberTests` 内にレイヤ別ファイルで追加できる命名規則 (`*_Tests.swift`) を定義。

### Chapter 3: 入力基盤仕様
- RealityKit.Input と GameController framework を抽象化する `InputGateway` プロトコルを設計し、HandTracking / PSVR2 実装クラスで実装する。
- プレイヤー状態は `PlayerInputState` 構造体で姿勢、ジェスチャー、ボタン状態を保持する。
- 60 fps 以上を維持するため、毎フレームの処理コスト計測 (os_signpost または MetricKit) の導入方針を決める。

### Chapter 4: ECS 戦闘フレーム仕様
- `SaberEntity`, `SaberComponent`, `SaberSystem` の命名規則とレイヤ配置を定義。
- RealityKit.PhysicsBody の contact API を利用した衝突イベントフロー (`CollisionEvent` -> `CombatSystem`) を図示。
- 戦闘フェーズ管理は `CombatPhase` enum + state machine で実装し、チュートリアル/ウェーブ/リザルトをステートで表現する。

### Chapter 5: QA & オペレーション
- コードレビュー時のチェックリスト (非推奨 API 使用禁止、60 fps 検証、空間 UI ガイドライン遵守) を策定。
- GitHub Actions での将来 CI 叩き台: `xcodebuild -scheme Saber -destination 'platform=visionOS' clean test` を nightly 実行する方針。
- 手動 QA プラン: ハンドトラッキング環境/PSVR2 Sense controller/低照度など代表シナリオでの動作確認項目を列挙。

## M1 Exit Criteria
- 上記章の仕様が Docs 配下にコミットされ、レビュー済みである。
- ディレクトリとプレースホルダーファイルが追加され、ビルド/テストが成功する。
- 次マイルストーンで即座に戦闘垂直スライス実装へ移行できる状態である。
