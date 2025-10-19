# Milestone M2: Battle Prototype & Device Validation

Document date: October 19, 2025  
Sprint window: Week 2 (per roadmap)

## Objectives
- Deliver a vertical slice duel on Apple Vision Pro hardware running visionOS 26.
- Support both hand tracking and PS VR2 Sense inputs with fast switching.
- Capture frame-time metrics to sustain >=60 fps (target 90 Hz).

## Scope

### Chapter 1: Input Pipeline
- Implement `HandTrackingInputGateway` backed by ARKit HandTrackingProvider to stream pose/velocity/gesture samples.
- Map PS VR2 Sense controllers via GameController.framework inside `SenseControllerInputGateway`.
- Expose input-source switching and status in RootCoordinator + HUD.
- Validation targets: 90 Hz hand updates on visionOS 26, PS VR2 Sense pairing and vibration readiness.

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
- Document Vision Pro deployment and PS VR2 Sense pairing.
- Checklist: (1) hand-only tracking, (2) controller swap, (3) collision feedback, (4) sustained 60+ fps sessions.
- Regression guardrails: immersive space toggling, input task shutdown, log export flow.

## Exit Criteria
- Simulator and device builds succeed with the above systems.
- Metric logs are produced and at least one device playtest report is captured.
- Follow-up polish items for Milestone M3 are tracked as issues.
