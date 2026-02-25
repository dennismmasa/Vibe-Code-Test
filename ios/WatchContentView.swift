import SwiftUI
import UserNotifications
import HealthKit

/// Watch-side SwiftUI view demonstrating HealthKit live workout integration.
struct WatchContentView: View {
    @StateObject private var hk = HealthKitManager.shared
    @State private var goalDistance = "10"
    @State private var goalTime = "50:00"
    @State private var tolerance = "5"
    @State private var lastStatus = ""
    @State private var resultText = ""
    @State private var simDistance: Double = 1.0
    @State private var simElapsed: TimeInterval = 5 * 60

    var body: some View {
        VStack(spacing: 8) {
            Text("Pace Watch Prototype").font(.headline)
            HStack { TextField("Goal km", text: $goalDistance).keyboardType(.decimalPad) }
            HStack { TextField("Goal time", text: $goalTime) }
            Button(action: startStop) { Text(hk.workoutSession == nil ? "Start" : "Stop") }

            // Debug controls for synthetic samples (quick testing)
            HStack(spacing: 8) {
                Button(action: { simulateSample() }) { Text("Simulate") }
                Button(action: { simDistance += 0.5 }) { Text("+0.5 km") }
                Button(action: { simElapsed += 60 }) { Text("+60s") }
            }

            Text("Sim: \(String(format: "%.2f", simDistance)) km • \(formatElapsed(simElapsed))")
                .font(.caption2)

            Text(resultText).font(.footnote).multilineTextAlignment(.center)
        }
        .padding()
        .onAppear { setup() }
    }

    func setup() {
        hk.requestAuthorization { ok, error in }

        // Wire WatchConnectivity
        let wc = WatchConnectivityManager_Watch.shared
        wc.onReceive = { msg in
            // handle messages from phone if desired
            print("Watch received: \(msg)")
        }

        hk.onSample = { distKm, elapsed in
            guard let gd = Double(goalDistance), let tol = Double(tolerance), distKm > 0 else { return }
            if let r = PaceEvaluator.evaluate(goalDistanceKm: gd, goalTimeStr: goalTime, distanceKm: distKm, elapsedStr: formatElapsed(elapsed), toleranceSecPerKm: tol) {
                DispatchQueue.main.async {
                    resultText = "\(r.status.capitalized) — \(r.currentPace) / \(r.targetPace)\nProjected: \(r.projectedFinish)"
                    if r.status != lastStatus {
                        sendLocalNotification(title: "Pace: \(r.status.uppercased())", body: "Projected: \(r.projectedFinish)")
                        lastStatus = r.status

                        // send to phone
                        let payload: [String: Any] = [
                            "event_type": "pace_update",
                            "status": r.status,
                            "target_pace": r.targetPace,
                            "current_pace": r.currentPace,
                            "pace_gap_sec_per_km": r.paceGapSecPerKm,
                            "projected_finish": r.projectedFinish,
                            "sent_at_epoch": Int(Date().timeIntervalSince1970)
                        ]
                        wc.sendPaceUpdate(payload)
                    }
                }
            }
        }
    }

    func startStop() {
        if hk.workoutSession == nil {
            hk.startWorkout()
        } else {
            hk.endWorkout()
        }
    }

    func formatElapsed(_ seconds: TimeInterval) -> String {
        let s = Int(round(seconds))
        let mm = s / 60
        let ss = s % 60
        return String(format: "%d:%02d", mm, ss)
    }

    // Emit a synthetic sample through the same pipeline used by HealthKit updates.
    func simulateSample() {
        // Call the same callback used by the HealthKit manager so UI and connectivity behave identical.
        hk.onSample?(simDistance, simElapsed)
    }

    func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(req) { _ in }
    }
}

// Preview
struct WatchContentView_Previews: PreviewProvider {
    static var previews: some View {
        WatchContentView()
    }
}
