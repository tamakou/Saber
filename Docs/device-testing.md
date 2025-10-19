# Device Test Checklist (visionOS 26)

## Prerequisites
- Xcode 16 with visionOS 26 SDK.
- Apple Vision Pro on visionOS 26 paired via Xcode.

## Build & Deploy
1. Open `Saber.xcodeproj` in Xcode 16.
2. Select the `Saber` scheme with the Vision Pro hardware target.
3. Run `Product > Build`.
4. Run `Product > Run` to install and launch.

## During Session
- Observe the Root window HUD for input status and latency.
- Enter the immersive space and confirm the duel loop activates using hand tracking.
- Play at least 5 minutes, logging notable events or hitches; test in varied room lighting and with/without hand accessories.

## Log Export
1. Quit the app on Vision Pro (Digital Crown double tap, swipe up).
2. In Xcode Devices window, download the app container.
3. Retrieve `frame_metrics.log` under `Library/Application Support/SaberMetrics/`.
4. Attach logs to the test report.

## Pass/Fail Criteria
- No crashes during the 5-minute session.
- HUD latency < 25 ms with consistent gesture recognition.
- Collision sparks + audio trigger on every saber impact.
- `frame_metrics.log` contains continuous sampling without gaps > 0.5 s.

## Post Test
- File issues with timestamps and log snippets.
- Update `Docs/test-reports/<date>.md` with summary and follow-ups.
