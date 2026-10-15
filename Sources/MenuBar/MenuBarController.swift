import Cocoa
import SwiftUI

public class MenuBarController: NSObject, NSMenuDelegate {
    public static let shared = MenuBarController()

    private var statusItem: NSStatusItem?
    private var menu: NSMenu?

    public var onOpenPreferences: (() -> Void)?
    public var onOpenAbout: (() -> Void)?

    private override init() {
        super.init()
    }

    public func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = MenuIcons.magnetStatusBarIcon()
            button.imagePosition = .imageOnly
            button.toolTip = "Miknatizale - Organize Your Workspace"
        }

        rebuildMenu()
    }

    public func rebuildMenu() {
        let newMenu = NSMenu()
        newMenu.delegate = self
        newMenu.autoenablesItems = false

        // Halves
        addMenuItem(to: newMenu, action: .left)
        addMenuItem(to: newMenu, action: .right)
        addMenuItem(to: newMenu, action: .top)
        addMenuItem(to: newMenu, action: .bottom)

        newMenu.addItem(NSMenuItem.separator())

        // Quarters
        addMenuItem(to: newMenu, action: .topLeft)
        addMenuItem(to: newMenu, action: .topRight)
        addMenuItem(to: newMenu, action: .bottomLeft)
        addMenuItem(to: newMenu, action: .bottomRight)

        newMenu.addItem(NSMenuItem.separator())

        // Thirds & Two Thirds
        addMenuItem(to: newMenu, action: .leftThird)
        addMenuItem(to: newMenu, action: .centerThird)
        addMenuItem(to: newMenu, action: .rightThird)
        addMenuItem(to: newMenu, action: .leftTwoThirds)
        addMenuItem(to: newMenu, action: .centerTwoThirds)
        addMenuItem(to: newMenu, action: .rightTwoThirds)

        newMenu.addItem(NSMenuItem.separator())

        // Sizing & Maximize
        addMenuItem(to: newMenu, action: .maximize)
        addMenuItem(to: newMenu, action: .almostMaximize)
        addMenuItem(to: newMenu, action: .maximizeHeight)
        addMenuItem(to: newMenu, action: .larger)
        addMenuItem(to: newMenu, action: .smaller)
        addMenuItem(to: newMenu, action: .center)
        addMenuItem(to: newMenu, action: .restore)

        newMenu.addItem(NSMenuItem.separator())

        // Submenus (only shown if at least one item inside is enabled)
        addSubmenu(to: newMenu, title: "Move to Edge",
                   actions: [.moveLeft, .moveRight, .moveUp, .moveDown])
        addSubmenu(to: newMenu, title: "Fourths",
                   actions: [.firstFourth, .secondFourth, .thirdFourth, .fourthFourth])
        addSubmenu(to: newMenu, title: "Sixths",
                   actions: [.topLeftSixth, .topCenterSixth, .topRightSixth,
                             .bottomLeftSixth, .bottomCenterSixth, .bottomRightSixth])

        // Displays
        newMenu.addItem(NSMenuItem.separator())
        addMenuItem(to: newMenu, action: .nextDisplay)
        addMenuItem(to: newMenu, action: .previousDisplay)

        newMenu.addItem(NSMenuItem.separator())

        // Ignore Current Frontmost App
        if let frontApp = NSWorkspace.shared.frontmostApplication,
           let appName = frontApp.localizedName,
           let bundleId = frontApp.bundleIdentifier,
           bundleId != Bundle.main.bundleIdentifier {
            let isIgnored = UserSettings.shared.isAppIgnored(bundleIdentifier: bundleId)
            let ignoreItem = NSMenuItem(
                title: "Ignore \(appName)",
                action: #selector(toggleIgnoreFrontApp(_:)),
                keyEquivalent: ""
            )
            ignoreItem.target = self
            ignoreItem.representedObject = bundleId
            ignoreItem.state = isIgnored ? .on : .off
            newMenu.addItem(ignoreItem)
            newMenu.addItem(NSMenuItem.separator())
        }

        // Dragging toggle
        let dragItem = NSMenuItem(
            title: "Window Dragging",
            action: #selector(toggleDragSnapping),
            keyEquivalent: ""
        )
        dragItem.target = self
        dragItem.state = UserSettings.shared.isDragSnappingEnabled ? .on : .off
        newMenu.addItem(dragItem)

        // Accessibility status
        let isTrusted = AccessibilityManager.shared.checkStatus(prompt: false)
        let accessItem = NSMenuItem(
            title: isTrusted ? "Accessibility Access: Granted" : "⚠️ Grant Accessibility Permission...",
            action: isTrusted ? nil : #selector(requestAccessibility),
            keyEquivalent: ""
        )
        accessItem.target = self
        accessItem.isEnabled = !isTrusted
        newMenu.addItem(accessItem)

        newMenu.addItem(NSMenuItem.separator())

        // Preferences
        let prefItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openPreferences),
            keyEquivalent: ","
        )
        prefItem.target = self
        prefItem.keyEquivalentModifierMask = [.command]
        newMenu.addItem(prefItem)

        // About
        let aboutItem = NSMenuItem(
            title: "About Miknatizale",
            action: #selector(openAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        newMenu.addItem(aboutItem)

        newMenu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit Miknatizale",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        quitItem.keyEquivalentModifierMask = [.command]
        newMenu.addItem(quitItem)

        Self.removeRedundantSeparators(in: newMenu)

        self.menu = newMenu
        self.statusItem?.menu = newMenu
    }

    private func addMenuItem(to menu: NSMenu, action: SnapAction) {
        // Respect the per-command "Show in menu bar" toggle from Preferences
        guard UserSettings.shared.isShownInMenu(action) else { return }

        let item = NSMenuItem(
            title: action.title,
            action: #selector(performSnapAction(_:)),
            keyEquivalent: ""
        )
        item.target = self
        item.representedObject = action
        item.image = MenuIcons.icon(for: action)

        let combo = UserSettings.shared.keyCombination(for: action)
        item.toolTip = "\(action.title) (\(combo.displayString))"

        menu.addItem(item)
    }

    private func addSubmenu(to menu: NSMenu, title: String, actions: [SnapAction]) {
        let submenu = NSMenu()
        submenu.autoenablesItems = false
        actions.forEach { addMenuItem(to: submenu, action: $0) }
        guard !submenu.items.isEmpty else { return }
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.submenu = submenu
        menu.addItem(item)
    }

    /// Removes leading, trailing and consecutive separators left behind by hidden groups.
    static func removeRedundantSeparators(in menu: NSMenu) {
        var previousWasSeparator = true // treat start as a separator to drop leading ones
        for item in menu.items {
            if item.isSeparatorItem {
                if previousWasSeparator { menu.removeItem(item) } else { previousWasSeparator = true }
            } else {
                previousWasSeparator = false
            }
        }
        if let last = menu.items.last, last.isSeparatorItem { menu.removeItem(last) }
    }

    @objc private func performSnapAction(_ sender: NSMenuItem) {
        guard let action = sender.representedObject as? SnapAction else { return }
        WindowManager.shared.snapActiveWindow(to: action)
    }

    @objc private func toggleIgnoreFrontApp(_ sender: NSMenuItem) {
        guard let bundleId = sender.representedObject as? String else { return }
        UserSettings.shared.toggleAppIgnored(bundleIdentifier: bundleId)
        rebuildMenu()
    }

    @objc private func toggleDragSnapping() {
        UserSettings.shared.isDragSnappingEnabled.toggle()
        rebuildMenu()
    }

    @objc private func requestAccessibility() {
        AccessibilityManager.shared.requestPermission()
    }

    @objc private func openPreferences() {
        onOpenPreferences?()
    }

    @objc private func openAbout() {
        onOpenAbout?()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    public func menuWillOpen(_ menu: NSMenu) {
        rebuildMenu()
    }
}
