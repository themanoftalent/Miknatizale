import Cocoa
import ApplicationServices
import Combine

public class AccessibilityManager: ObservableObject {
    public static let shared = AccessibilityManager()

    @Published public var isGranted: Bool = false
    private var pollTimer: Timer?

    private init() {
        self.isGranted = checkStatus(prompt: false)
        startPollingIfNeeded()
    }

    public func checkStatus(prompt: Bool = false) -> Bool {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: prompt
        ]
        let trusted = AXIsProcessTrustedWithOptions(options)
        if self.isGranted != trusted {
            DispatchQueue.main.async {
                self.isGranted = trusted
            }
        }
        return trusted
    }

    public func requestPermission() {
        _ = checkStatus(prompt: true)
        openAccessibilitySettings()
        startPollingIfNeeded()
    }

    public func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    public func startPollingIfNeeded() {
        guard pollTimer == nil else { return }
        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let trusted = self.checkStatus(prompt: false)
            if trusted {
                self.isGranted = true
                timer.invalidate()
                self.pollTimer = nil
            }
        }
    }

    deinit {
        pollTimer?.invalidate()
    }
}
