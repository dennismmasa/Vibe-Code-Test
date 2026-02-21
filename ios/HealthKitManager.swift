import Foundation
import HealthKit

/// Lightweight HealthKit helper for starting a live workout and streaming distance + elapsed time.
public class HealthKitManager: NSObject, ObservableObject {
    public static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?

    @Published public private(set) var currentDistanceKm: Double = 0
    @Published public private(set) var elapsedSeconds: TimeInterval = 0

    /// Called whenever a pacing update is available (distance, elapsed).
    public var onSample: ((Double, TimeInterval) -> Void)?

    public func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }

        let types: Set = [HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                          HKObjectType.quantityType(forIdentifier: .heartRate)!]

        healthStore.requestAuthorization(toShare: [], read: types) { ok, error in
            DispatchQueue.main.async { completion(ok, error) }
        }
    }

    public func startWorkout() {
        let config = HKWorkoutConfiguration()
        config.activityType = .running
        config.locationType = .outdoor

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
            workoutBuilder?.delegate = self
            workoutSession?.delegate = self

            workoutBuilder?.beginCollection(withStart: Date()) { (success, error) in
                // started builder
            }

            workoutSession?.startActivity(with: Date())
        } catch {
            print("Failed to start workout: \(error)")
        }
    }

    public func endWorkout() {
        workoutSession?.end()
        workoutBuilder?.endCollection(withEnd: Date()) { _, _ in }
    }
}

// MARK: - HKWorkoutBuilderDelegate / HKWorkoutSessionDelegate
extension HealthKitManager: HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate {
    public func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // no-op
    }

    public func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) {
        // Pull latest distance and elapsed
        if let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            let statistics = workoutBuilder.statistics(for: distanceType)
            if let sum = statistics?.sumQuantity() {
                let meters = sum.doubleValue(for: HKUnit.meter())
                let km = meters / 1000.0
                DispatchQueue.main.async {
                    self.currentDistanceKm = km
                    // elapsed: builder's elapsed time
                    self.elapsedSeconds = workoutBuilder.elapsedTime
                    self.onSample?(self.currentDistanceKm, self.elapsedSeconds)
                }
            }
        }
    }

    public func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // handle state changes if needed
    }

    public func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session error: \(error)")
    }
}
