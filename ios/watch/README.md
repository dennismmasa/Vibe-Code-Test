WatchOS Companion
=================

These files are prototypes to copy into a WatchKit App / WatchKit Extension target.

Integration steps:
1. In Xcode, add a Watch target (File → New → Target → WatchKit App). Choose SwiftUI lifecycle.
2. Add `PaceEvaluator.swift` and `HealthKitManager.swift` into the WatchKit Extension target (check the target box in file inspector).
3. Replace the generated `ContentView.swift` in the WatchKit Extension with `WatchContentView.swift` provided here.
4. In Capabilities, enable `HealthKit` and `Background Modes` → `Workout Processing`.
5. On the watch device (not Simulator) run the Watch app and grant Health permissions when prompted.

Notes:
- For a production app, use `HKLiveWorkoutBuilder` updates to also feed complications and extend notification handling.
- Consider using `WatchConnectivity` to mirror events back to the phone app if desired.
