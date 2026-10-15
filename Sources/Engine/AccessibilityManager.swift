import Cocoa
import ApplicationServices
import Combine

public class AccessibilityManager: ObservableObject {
    public static let shared = AccessibilityManager()

    @Published public var isGranted: Bool = false
    private var pollTimer: Timer?

    private init() {
        self.isGranted = AXIsProcessTrusted()
        startPollingIfNeeded()
    }

    /// Checks the current accessibility trust status.
    /// - Parameter prompt: If true, requests macOS to present the system authorization prompt if not yet trusted.
    /// - Returns: True if accessibility is trusted for this application.
    @discardableResult
    public func checkStatus(prompt: Bool = false) -> Bool {
        let trusted: Bool
        if prompt {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            trusted = AXIsProcessTrustedWithOptions(options)
        } else {
            trusted = AXIsProcessTrusted()
        }

        if self.isGranted != trusted {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isGranted = trusted
                if trusted {
                    self.handlePermissionGranted()
                } else {
                    MenuBarController.shared.rebuildMenu()
                }
            }
        }
        return trusted
    }

    /// Requests permission.
    /// First time: shows only the macOS "Device Control and Data Access" dialog
    /// (its own "Open System Settings" button takes the user there).
    /// Later clicks: macOS won't show the dialog again, so we open System Settings directly.
    public func requestPermission() {
        if AXIsProcessTrusted() {
            handlePermissionGranted()
            return
        }

        let promptedKey = "Miknatizale_AXPromptShown"
        if !UserDefaults.standard.bool(forKey: promptedKey) {
            UserDefaults.standard.set(true, forKey: promptedKey)
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            _ = AXIsProcessTrustedWithOptions(options)
        } else {
            openAccessibilitySettings()
        }
        startPollingIfNeeded()
    }

    /// Opens System Settings directly to Privacy & Security -> Accessibility and brings it to the front.
    public func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.systempreferences").first {
                app.activate(options: .activateAllWindows)
            }
        }
    }

    /// Starts a recurring timer on RunLoop.main in .common mode so it runs reliably even when menus or modals are open.
    public func startPollingIfNeeded() {
        guard pollTimer == nil else { return }
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let trusted = AXIsProcessTrusted()
            if trusted {
                if !self.isGranted {
                    self.handlePermissionGranted()
                }
            } else {
                if self.isGranted {
                    DispatchQueue.main.async {
                        self.isGranted = false
                        MenuBarController.shared.rebuildMenu()
                    }
                }
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.pollTimer = timer
    }

    /// Executed whenever accessibility permission becomes granted.
    private func handlePermissionGranted() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isGranted = true
            MenuBarController.shared.rebuildMenu()
            HotKeyManager.shared.registerAll()
            DragSnapManager.shared.startMonitoring()
        }
    }

    deinit {
        pollTimer?.invalidate()
    }
}
