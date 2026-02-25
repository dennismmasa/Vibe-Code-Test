import Foundation

public struct PaceResult: Codable {
    public let status: String
    public let targetPace: String
    public let currentPace: String
    public let paceGapSecPerKm: Double
    public let projectedFinish: String
}

public enum PaceEvaluator {
    // Parse time strings: seconds, mm:ss, or hh:mm:ss
    public static func parseTime(_ s: String) -> TimeInterval? {
        let parts = s.split(separator: ":").map { String($0) }
        if parts.count == 1 {
            return TimeInterval(Double(parts[0]) ?? 0)
        } else if parts.count == 2 {
            guard let mm = Double(parts[0]), let ss = Double(parts[1]) else { return nil }
            return mm * 60 + ss
        } else if parts.count == 3 {
            guard let hh = Double(parts[0]), let mm = Double(parts[1]), let ss = Double(parts[2]) else { return nil }
            return hh * 3600 + mm * 60 + ss
        } else {
            return nil
        }
    }

    static func formatTimeComponents(_ seconds: TimeInterval) -> String {
        let s = Int(round(seconds))
        if s >= 3600 {
            let hh = s / 3600
            let mm = (s % 3600) / 60
            let ss = s % 60
            return String(format: "%d:%02d:%02d", hh, mm, ss)
        } else {
            let mm = s / 60
            let ss = s % 60
            return String(format: "%d:%02d", mm, ss)
        }
    }

    static func formatPacePerKm(_ secondsPerKm: TimeInterval) -> String {
        let s = Int(round(secondsPerKm))
        let mm = s / 60
        let ss = s % 60
        return String(format: "%d:%02d /km", mm, ss)
    }

    public static func evaluate(goalDistanceKm: Double,
                                goalTimeStr: String,
                                distanceKm: Double,
                                elapsedStr: String,
                                toleranceSecPerKm: Double = 5.0) -> PaceResult? {
        guard let goalTime = parseTime(goalTimeStr), goalDistanceKm > 0 else { return nil }
        guard let elapsed = parseTime(elapsedStr), distanceKm > 0 else { return nil }

        let targetPaceSec = goalTime / goalDistanceKm
        let currentPaceSec = elapsed / distanceKm
        let paceGap = currentPaceSec - targetPaceSec

        let status: String
        if abs(paceGap) <= toleranceSecPerKm {
            status = "on pace"
        } else if paceGap < 0 {
            status = "ahead"
        } else {
            status = "behind"
        }

        let remaining = max(goalDistanceKm - distanceKm, 0)
        let projectedFinishSec = elapsed + remaining * currentPaceSec

        return PaceResult(
            status: status,
            targetPace: formatPacePerKm(targetPaceSec),
            currentPace: formatPacePerKm(currentPaceSec),
            paceGapSecPerKm: paceGap,
            projectedFinish: formatTimeComponents(projectedFinishSec)
        )
    }
}
