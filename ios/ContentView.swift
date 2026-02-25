import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var goalDistance = "10"
    @State private var goalTime = "50:00"
    @State private var distance = "4.2"
    @State private var elapsed = "20:30"
    @State private var tolerance = "5"

    @State private var lastStatus: String = ""
    @State private var resultText: String = ""
    @StateObject private var wc = WatchConnectivityManager.shared

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal")) {
                    TextField("Goal distance (km)", text: $goalDistance)
                        .keyboardType(.decimalPad)
                    TextField("Goal time (mm:ss or hh:mm:ss)", text: $goalTime)
                }

                Section(header: Text("Current")) {
                    TextField("Distance (km)", text: $distance)
                        .keyboardType(.decimalPad)
                    TextField("Elapsed (mm:ss)", text: $elapsed)
                }

                Section(header: Text("Options")) {
                    TextField("Tolerance sec/km", text: $tolerance)
                        .keyboardType(.numberPad)
                    Button("Evaluate") { evaluate() }
                }

                Section(header: Text("Result")) {
                    Text(resultText).fixedSize(horizontal: false, vertical: true)
                }
            }
            .navigationTitle("Pace Prototype")
            .onAppear { requestNotificationPermission() }
        }
    }

    func evaluate() {
        guard let gd = Double(goalDistance), let dist = Double(distance), let tol = Double(tolerance) else {
            resultText = "Invalid numeric inputs"
            return
        }
        guard let r = PaceEvaluator.evaluate(goalDistanceKm: gd, goalTimeStr: goalTime, distanceKm: dist, elapsedStr: elapsed, toleranceSecPerKm: tol) else {
            resultText = "Could not evaluate — check time formats"
            return
        }

        resultText = "Status: \(r.status)\nTarget pace: \(r.targetPace)\nCurrent pace: \(r.currentPace)\nPace gap: \(String(format: "%.2f", r.paceGapSecPerKm)) sec/km\nProjected finish: \(r.projectedFinish)"

        if r.status != lastStatus {
            sendLocalNotification(title: "Pace: \(r.status.uppercased())", body: "\(r.currentPace) vs \(r.targetPace). Projected: \(r.projectedFinish)")
            // send to watch/phone counterpart
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
            lastStatus = r.status
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            // ignore for prototype
        }
    }

    func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(req) { error in
            // ignore errors for prototype
        }
    }
}

// SwiftUI preview
import PlaygroundSupport
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
