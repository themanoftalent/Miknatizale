import Cocoa
import SwiftUI

public class AppDelegate: NSObject, NSApplicationDelegate {
    private var preferencesWindow: NSWindow?
    private var aboutWindow: NSWindow?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as menu bar agent / accessory
        NSApp.setActivationPolicy(.accessory)

        // Setup Menu Bar Item
        MenuBarController.shared.setup()
        MenuBarController.shared.onOpenPreferences = { [weak self] in
            self?.openPreferences()
        }
        MenuBarController.shared.onOpenAbout = { [weak self] in
            self?.openAbout()
        }

        // Register Global Carbon Shortcuts
        HotKeyManager.shared.registerAll()

        // Start Drag-to-Snap Monitoring
        DragSnapManager.shared.startMonitoring()

        // Check Accessibility permissions
        let isTrusted = AccessibilityManager.shared.checkStatus(prompt: false)
        if !isTrusted {
            // Open preferences on first launch if accessibility isn't granted yet
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.openPreferences()
            }
        }
    }

    public func openPreferences() {
        if let window = preferencesWindow {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }

        let preferencesView = PreferencesView()
        let hostingController = NSHostingController(rootView: preferencesView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 660),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Miknatizale Preferences"
        window.contentViewController = hostingController
        window.isReleasedWhenClosed = false

        self.preferencesWindow = window

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    public func openAbout() {
        if let window = aboutWindow {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }

        let aboutView = AboutView()
        let hostingController = NSHostingController(rootView: aboutView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "About Miknatizale"
        window.contentViewController = hostingController
        window.isReleasedWhenClosed = false

        self.aboutWindow = window

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    public func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregisterAll()
        DragSnapManager.shared.stopMonitoring()
    }
}
