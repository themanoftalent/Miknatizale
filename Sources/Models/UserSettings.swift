import Foundation
import Combine
import SwiftUI
import Carbon

public class UserSettings: ObservableObject {
    public static let shared = UserSettings()

    private let shortcutsKey = "Miknatizale_Shortcuts"
    private let dragTriggersKey = "Miknatizale_DragTriggers"
    private let dragSnappingEnabledKey = "Miknatizale_DragSnappingEnabled"
    private let cycleKey = "Miknatizale_CycleRepeatedPresses"
    private let windowGapKey = "Miknatizale_WindowGap"
    private let launchAtLoginKey = "Miknatizale_LaunchAtLogin"
    private let playFeedbackSoundKey = "Miknatizale_PlayFeedbackSound"
    private let ignoredAppsKey = "Miknatizale_IgnoredApps"
    private let activePresetKey = "Miknatizale_ActivePreset"

    @Published public var shortcuts: [SnapAction: KeyCombination] = [:] {
        didSet { saveShortcuts() }
    }

    @Published public var dragTriggers: [SnapAction: Bool] = [:] {
        didSet { saveDragTriggers() }
    }

    @Published public var isDragSnappingEnabled: Bool {
        didSet { UserDefaults.standard.set(isDragSnappingEnabled, forKey: dragSnappingEnabledKey) }
    }

    @Published public var cycleRepeatedPresses: Bool {
        didSet { UserDefaults.standard.set(cycleRepeatedPresses, forKey: cycleKey) }
    }

    @Published public var windowGap: CGFloat {
        didSet { UserDefaults.standard.set(windowGap, forKey: windowGapKey) }
    }

    @Published public var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: launchAtLoginKey) }
    }

    @Published public var playFeedbackSound: Bool {
        didSet { UserDefaults.standard.set(playFeedbackSound, forKey: playFeedbackSoundKey) }
    }

    @Published public var ignoredBundleIdentifiers: Set<String> = [] {
        didSet { saveIgnoredApps() }
    }

    @Published public var activePreset: String {
        didSet { UserDefaults.standard.set(activePreset, forKey: activePresetKey) }
    }

    public init() {
        self.isDragSnappingEnabled = UserDefaults.standard.object(forKey: dragSnappingEnabledKey) as? Bool ?? true
        self.cycleRepeatedPresses = UserDefaults.standard.object(forKey: cycleKey) as? Bool ?? true
        self.windowGap = UserDefaults.standard.object(forKey: windowGapKey) as? CGFloat ?? 0.0
        self.launchAtLogin = UserDefaults.standard.object(forKey: launchAtLoginKey) as? Bool ?? false
        self.playFeedbackSound = UserDefaults.standard.object(forKey: playFeedbackSoundKey) as? Bool ?? false
        self.activePreset = UserDefaults.standard.string(forKey: activePresetKey) ?? "Rectangle"

        loadIgnoredApps()
        loadShortcuts()
        loadDragTriggers()
    }

    public func keyCombination(for action: SnapAction) -> KeyCombination {
        return shortcuts[action] ?? action.defaultKeyCombination
    }

    public func setKeyCombination(_ combination: KeyCombination, for action: SnapAction) {
        shortcuts[action] = combination
        activePreset = "Custom"
    }

    public func isDragTriggerEnabled(for action: SnapAction) -> Bool {
        return dragTriggers[action] ?? true
    }

    public func setDragTriggerEnabled(_ enabled: Bool, for action: SnapAction) {
        dragTriggers[action] = enabled
    }

    public func isAppIgnored(bundleIdentifier: String) -> Bool {
        return ignoredBundleIdentifiers.contains(bundleIdentifier)
    }

    public func toggleAppIgnored(bundleIdentifier: String) {
        if ignoredBundleIdentifiers.contains(bundleIdentifier) {
            ignoredBundleIdentifiers.remove(bundleIdentifier)
        } else {
            ignoredBundleIdentifiers.insert(bundleIdentifier)
        }
    }

    public func applyRectanglePreset() {
        self.shortcuts = RectangleImporter.shared.importShortcuts()
        self.activePreset = "Rectangle"
    }

    public func applyMagnetPreset() {
        self.shortcuts = RectangleImporter.shared.defaultMagnetShortcuts()
        self.activePreset = "Magnet"
    }

    public func resetToDefaults() {
        applyRectanglePreset()
        var defaultTriggers: [SnapAction: Bool] = [:]
        for action in SnapAction.allCases {
            defaultTriggers[action] = true
        }
        self.dragTriggers = defaultTriggers
        self.isDragSnappingEnabled = true
        self.cycleRepeatedPresses = true
        self.windowGap = 0.0
        self.playFeedbackSound = false
        self.ignoredBundleIdentifiers.removeAll()
    }

    private func loadShortcuts() {
        // If user already saved custom shortcuts in Miknatizale, load them
        if let data = UserDefaults.standard.data(forKey: shortcutsKey),
           let decoded = try? JSONDecoder().decode([String: KeyCombination].self, from: data) {
            var loaded: [SnapAction: KeyCombination] = [:]
            for (key, combo) in decoded {
                if let action = SnapAction(rawValue: key) {
                    loaded[action] = combo
                }
            }
            // Fill any missing actions with defaults
            for action in SnapAction.allCases {
                if loaded[action] == nil {
                    loaded[action] = action.defaultKeyCombination
                }
            }
            // Ensure Bottom Right is explicitly Control + Command + Down Arrow
            let ctrlCmd = UInt32(controlKey | cmdKey)
            loaded[.bottomRight] = KeyCombination(keyCode: UInt32(kVK_DownArrow), carbonModifiers: ctrlCmd)

            self.shortcuts = loaded
            return
        }

        // On first launch: automatically import directly from the user's Rectangle!
        if RectangleImporter.shared.isRectangleInstalled {
            self.shortcuts = RectangleImporter.shared.importShortcuts()
            self.activePreset = "Rectangle (Imported)"
        } else {
            var loaded: [SnapAction: KeyCombination] = [:]
            for action in SnapAction.allCases {
                loaded[action] = action.defaultKeyCombination
            }
            self.shortcuts = loaded
        }
    }

    private func saveShortcuts() {
        var toSave: [String: KeyCombination] = [:]
        for (action, combo) in shortcuts {
            toSave[action.rawValue] = combo
        }
        if let data = try? JSONEncoder().encode(toSave) {
            UserDefaults.standard.set(data, forKey: shortcutsKey)
        }
    }

    private func loadDragTriggers() {
        var loaded: [SnapAction: Bool] = [:]
        for action in SnapAction.allCases {
            loaded[action] = true
        }

        if let dict = UserDefaults.standard.dictionary(forKey: dragTriggersKey) as? [String: Bool] {
            for (key, val) in dict {
                if let action = SnapAction(rawValue: key) {
                    loaded[action] = val
                }
            }
        }
        self.dragTriggers = loaded
    }

    private func saveDragTriggers() {
        var toSave: [String: Bool] = [:]
        for (action, val) in dragTriggers {
            toSave[action.rawValue] = val
        }
        UserDefaults.standard.set(toSave, forKey: dragTriggersKey)
    }

    private func loadIgnoredApps() {
        if let list = UserDefaults.standard.stringArray(forKey: ignoredAppsKey) {
            self.ignoredBundleIdentifiers = Set(list)
        }
    }

    private func saveIgnoredApps() {
        UserDefaults.standard.set(Array(ignoredBundleIdentifiers), forKey: ignoredAppsKey)
    }
}
