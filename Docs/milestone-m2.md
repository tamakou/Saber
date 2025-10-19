# Milestone M2: Battle Prototype & Device Validation

Document date: October 19, 2025  
Sprint window: Week 2 (per roadmap)

## Objectives
- Ship a vertical slice duel that can run exclusively on Apple Vision Pro hardware under visionOS 26.
- Mature the hand-tracking input pipeline and route combat events into the ECS stack.
- Introduce performance instrumentation to keep the frame rate at 60+ fps (target 90 Hz) and capture logs for analysis.

## Scope

### Chapter 1: Input Pipeline
- Implement `HandTrackingInputGateway` backed by ARKit HandTrackingProvider to stream pose/velocity/gesture samples.
- Surface pipeline status within RootCoordinator + HUD so users can confirm when hand tracking is live.
- Validation targets: 90 Hz hand updates on visionOS 26 and reliable gesture classification across lighting conditions.

### Chapter 2: Saber Core
- Synchronize player saber transforms through `SaberEntity` and delegate collisions/combos to `BattleCoordinator`.
- Stub luminous VFX and audio hooks triggered on impact events.

### Chapter 3: Enemy & Phase Flow
- Create `EnemyEntity` state machine (idle, telegraph, strike, recover) and expand `DefaultCombatSystem` with duel/victory/defeat states.
- Surface health, combo, score, and latency in the combat HUD.

### Chapter 4: Performance & Logging
- Wire `MetricLogger` to `os.Logger` + Application Support file output for frame times and input latency.
- Configure Debug/Profile builds for Metal validation and `OS_ACTIVITY_MODE` control.

### Chapter 5: Device Test Protocol
- Document Vision Pro deployment flow and hand-tracking calibration steps.
- Checklist: (1) hand-only tracking accuracy, (2) collision feedback, (3) sustained 60+ fps sessions.
- Regression guardrails: immersive space toggling, input task shutdown, log export flow.

## Exit Criteria
- Simulator + device builds succeed with the above systems.
- Metric logs are produced and at least one device playtest report is captured.
- Follow-up polish items for Milestone M3 are tracked as issues.
