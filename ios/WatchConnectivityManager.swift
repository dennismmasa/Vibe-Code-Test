import Foundation
import WatchConnectivity

public class WatchConnectivityManager: NSObject, ObservableObject {
    public static let shared = WatchConnectivityManager()
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    /// Called when a message/userInfo arrives
    public var onReceive: (([String: Any]) -> Void)?

    private override init() {
        super.init()
        session?.delegate = self
        session?.activate()
    }

    public func sendPaceUpdate(_ payload: [String: Any]) {
        guard let session = session else { return }
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil) { error in
                print("WC sendMessage error: \(error)")
            }
        } else {
            session.transferUserInfo(payload)
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // no-op
    }

    public func sessionDidBecomeInactive(_ session: WCSession) {}
    public func sessionDidDeactivate(_ session: WCSession) { session.activate() }

    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async { self.onReceive?(message) }
    }

    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        DispatchQueue.main.async { self.onReceive?(userInfo) }
    }
}
