# Saber Requirements Definition (v0.1)

**Document date:** October 19, 2025  
**Target release:** Public launch aligned with visionOS 26 general availability (September 15, 2025)  
**Project owner:** Solo developer (tamakou)  

## 1. Product Vision
- Deliver a cinematic, single-player lightsaber battle fantasy on Apple Vision Pro that evokes iconic sci-fi duels without infringing on licensed IP.
- Prioritize immediacy ("ultra-fast (bakusoku)") by focusing on a polished vertical slice that can grow into a premium paid title or showcase for spatial combat.

## 2. Scope Overview
- **In scope:** Core combat loop vs. AI opponents, tactile haptics, training dojo environment, narrative-light progression, leaderboard-ready telemetry.
- **Out of scope (v1):** Multiplayer networking, licensed characters/voices, cross-platform support, long-form campaign, modding tools.

## 3. Target Platform & Hardware
- **Operating system:** visionOS 26 (build for visionOS 26 SDK; maintain fallback plans for 2.x users if feasible).  
- **Hardware:** Apple Vision Pro with hand tracking and optional accessories (PlayStation VR2 Sense controllers, gamepad, keyboard). Support standing room-scale and seated play.
- **Performance target:** 90 Hz rendering for input-responsive combat; allow 96 Hz on ProMotion if scene complexity permits.

## 4. Design Pillars
1. **Heroic Combat:** Lightsaber mechanics feel weighty and reactive with minimal latency.  
2. **Spatial Presence:** Opponents, effects, and UI respect physical space and blend with the player's room.  
3. **Accessible Mastery:** Onboarding teaches gestures quickly; depth comes from timing, stance, and Force-like abilities.  
4. **Rapid Iteration:** Architecture favors modular content drops (new enemies, arenas, challenges) to sustain speed.

## 5. User Personas & Jobs-To-Be-Done
- **Immersive Action Fan (primary):** Wants a premium, short-session experience demonstrating Vision Pro's combat potential.
- **AR Showcase Seeker:** Needs a jaw-dropping demo for friends or events; values instant setup and replayability.
- **Fitness-Oriented Player:** Expects calorie-burning swordplay with metrics and adaptive pacing.

## 6. Core Experience Requirements
### 6.1 Gameplay Loop
1. Player selects scenario (training gauntlet, boss duel, survival).  
2. Brief holographic briefing/tutorial overlays.  
3. Combat encounter with adaptive AI waves.  
4. Post-battle scoring, progression unlocks (saber hilts, stances, VFX).

### 6.2 Combat Systems
- **Saber Mechanics:** One-to-one blade tracking with visual trails, collision sparks, parry windows, and deflection physics.  
- **Force-like Abilities:** Limited-use telekinetic push/pull to stagger foes or redirect blaster bolts.  
- **Enemy Archetypes:** Melee droid, dual-wield elite, ranged trooper. Each exposes different defensive/offensive timing.  
- **Difficulty Scaling:** Adjust enemy aggression, damage, and parry timing. Unlock "Master" mode after clear.

### 6.3 Progression & Rewards
- Skill-based star ratings per encounter; unlock cosmetics and modifiers.
- Optional daily challenges with leaderboards (local first, online optional future).

## 7. Interaction & Controls
- **Hand/Gesture Tracking:** Leverage 90 Hz hand tracking improvements in visionOS 26 for low-latency blade control and gesture recognition.  
- **Eye Interaction:** Use Look-to-Scroll paradigms for menus; avoid accidental activation by requiring gentle pinch confirm.  
- **Controller Support:** Implement Game Controller framework updates for PlayStation VR2 Sense controllers (dual wield, haptics, adaptive triggers). Provide fallback for standard Bluetooth gamepads.  
- **Haptics:** Use spatial audio + controller vibration (when available) to convey hits; fallback to audio cues for hand-tracking-only mode.  
- **Comfort:** Offer seated mode, boundary visualization, and travel mode compatibility checks.

## 8. Spatial UX & Presentation
- Environments blend volumetric set dressing with passthrough surfaces; incorporate optional fully immersive "hangar" Environment.  
- Utilize volumetric SwiftUI and Dynamic Bounds Restrictions to pin HUD elements (health, combo, cooldowns) within a volumetric cockpit anchored near the player's dominant hand.  
- Provide spatial widgets for quick-access stats, daily challenge timers, and training reminders in the user's Shared Space.

## 9. Audio & Music
- Original score inspired by heroic orchestral motifs; dynamic layers based on combat intensity.  
- Spatialized saber hum tied to blade position; positional audio for enemy cues.  
- Voiceover limited to AI guide + combat barks (no licensed content).

## 10. Technical Requirements & Stack
- **Languages:** Swift 6 for app code, small C++ modules if low-level Metal optimizations required.  
- **Frameworks:** RealityKit (volumetric rendering, physics), ARKit (plane/room understanding, accessory anchors), SwiftUI (volumetric UI), TabletopKit for spatial accessory integration, Game Controller framework (PSVR2 Sense).  
- **Tools:** Xcode 26 (visionOS 26 SDK), Reality Composer Pro for scene authoring, Motion capture pipeline (Blender + USDZ export).  
- **Build & CI:** Swift Package Manager; GitHub Actions for lint/build/test matrix (visionOS simulator).  
- **Analytics:** Lightweight in-app logging with privacy-friendly event batching (opt-in).  
- **Testing Devices:** Vision Pro hardware (developer-owned), simulator for smoke tests.

## 11. Content Production Pipeline
- **Art:** Procedural saber VFX with Metal shaders; stylized droid designs to avoid IP overlap.  
- **Animation:** Motion capture for humanoid enemies, retargeted via USD/RealityKit; physics-driven ragdoll on defeat.  
- **Audio:** Design custom saber sounds with layered synthesis + field recordings; integrate via AVAudioEngine.  
- **Localization:** Start with English; structure string tables for future expansion (visionOS 26 adds wider language support).

## 12. Performance, Stability & QA
- Target <15 ms motion-to-photon latency; monitor via Xcode's spatial debugging tools.  
- Maintain 90 Hz baseline; adapt level-of-detail via Dynamic Render Quality when GPU load spikes.  
- Memory budget adheres to updated visionOS 26 allowances for immersive games; stream assets to avoid spikes.  
- Implement automated unit tests for combat logic, gesture recognition; nightly integration tests on simulator.  
- Manual playtests for comfort, motion sickness, and tracking edge cases (low light, occluded hands).

## 13. Security & Privacy
- Store only anonymized progression data locally.  
- No biometric or raw sensor data leaves device.  
- Respect enterprise APIs safeguards when running in managed environments.

## 14. Accelerated Delivery Roadmap (Indicative)
- **Week 0-1:** Finalize requirements, set up Xcode 26 workspace, CI, and core modules.  
- **Week 2-4:** Prototype saber tracking, enemy AI sandbox, basic UI volumes.  
- **Week 5-6:** Implement PSVR2 Sense support, combat feel tuning, VFX passes.  
- **Week 7-8:** Build tutorial dojo, add audio system, integrate scoring and progression.  
- **Week 9:** Performance optimization, QA pass on hardware, accessibility tweaks.  
- **Week 10:** Content polish (animations, shaders, VO), prepare app metadata.  
- **Week 11:** Beta testing with trusted users, bug triage, marketing capture.  
- **Week 12:** App Store submission (TestFlight, review assets), launch prep.

## 15. Risks & Mitigations
- **IP Similarity:** Maintain generic sci-fi aesthetic; legal review before launch.  
- **Tracking Reliability:** Provide fallback gestures, recalibration prompts, and PSVR2 controller option.  
- **Scope Creep:** Lock MVP feature set; backlog for post-launch updates.  
- **Performance Regression:** Continuous profiling, automatic alerts in CI when frame timing fails thresholds.  
- **Solo Developer Bandwidth:** Time-box features, leverage asset marketplaces, automate build/test.

## 16. Success Metrics (MVP)
- 30% of sessions reach second-tier difficulty.  
- Average play session >=12 minutes.  
- App Store rating >=4.5 after 100 reviews.  
- Crash-free sessions >=99% across supported hardware.  
- Day-30 retention >=25% for early adopters.

## 17. References
1. Apple Newsroom. "visionOS 26 introduces powerful new spatial experiences for Apple Vision Pro." Published June 9, 2025.  
2. Apple Developer. "What's new in visionOS 26." Accessed October 19, 2025.  
3. MacRumors. "Apple releases visionOS 26 with persistent widgets, lifelike Personas, and spatial scenes for Vision Pro." Published September 15, 2025.  
4. The Verge. "Apple's visionOS 26 adds PSVR2 controller support and spatial widgets to the Vision Pro." Published June 9, 2025.
