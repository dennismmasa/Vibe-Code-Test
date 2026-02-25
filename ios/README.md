iOS Native Prototype
=====================

This folder contains a minimal SwiftUI prototype to run the pace-evaluation logic on iPhone / Simulator.

Quick steps to try it in Xcode:

1. Open Xcode and create a new project: **App** > **iOS** > **App** using Swift and SwiftUI lifecycle.
2. Replace the generated `ContentView.swift` with the `ContentView.swift` in this folder.
3. Add `PaceEvaluator.swift` from this folder to your project.
4. In the project settings enable **Background Modes** if you plan to run background updates, and add **HealthKit** entitlement if you will integrate HealthKit live data.
5. Request notification permission when running on device to receive local alerts.

Files provided:
- `PaceEvaluator.swift` — core pace parsing and evaluate logic ported from `pace_tracker.py`.
- `ContentView.swift` — a SwiftUI view demonstrating UI inputs and local notification on status change.

Notes:
- This is a prototype: for production on Apple Watch, port the logic into an `HKLiveWorkoutBuilder` session and send notifications from workout session updates.
- To test notifications in Simulator: use the Notification Center; best to test on a device for haptics.
