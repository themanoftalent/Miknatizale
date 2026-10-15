import Cocoa
import ApplicationServices
import AudioToolbox

public class WindowManager {
    public static let shared = WindowManager()

    // History of window frames before snapping for "Restore"
    private var windowRestoreFrames: [pid_t: CGRect] = [:]

    // Cycle tracking for repeated shortcut presses
    private var lastAction: SnapAction?
    private var lastActionTime: Date?
    private var lastTargetRect: CGRect?

    private init() {}

    /// Performs the given snap action on the currently focused/active window
    @discardableResult
    public func snapActiveWindow(to action: SnapAction) -> Bool {
        guard AccessibilityManager.shared.checkStatus(prompt: false) else {
            NSSound.beep()
            return false
        }

        guard let (_, windowElement, pid) = getFrontmostWindow() else {
            NSSound.beep()
            return false
        }

        // Determine effective action (handles repeated key press cycling)
        let effectiveAction = resolveCycleAction(for: action, windowElement: windowElement)

        // Read current window geometry
        guard let currentRect = getWindowRect(windowElement) else {
            return false
        }

        // Handle Restore
        if effectiveAction == .restore {
            if let savedRect = windowRestoreFrames[pid] {
                setWindowRect(windowElement, targetRect: savedRect)
                windowRestoreFrames.removeValue(forKey: pid)
                playFeedback()
                return true
            }
            return false
        }

        // Save pre-snap frame for restore if not already saved during this session
        if windowRestoreFrames[pid] == nil {
            windowRestoreFrames[pid] = currentRect
        }

        // Find current screen for the window
        let currentScreen = ScreenManager.shared.screenFor(windowQuartzRect: currentRect)

        // Handle Multi-Display actions
        if effectiveAction == .nextDisplay || effectiveAction == .previousDisplay {
            let targetScreen = (effectiveAction == .nextDisplay)
                ? ScreenManager.shared.nextScreen(from: currentScreen)
                : ScreenManager.shared.previousScreen(from: currentScreen)

            let sourceVisible = ScreenManager.shared.visibleQuartzFrame(for: currentScreen)
            let targetVisible = ScreenManager.shared.visibleQuartzFrame(for: targetScreen)

            // Proportional scaling from source screen to target screen
            let relX = (currentRect.minX - sourceVisible.minX) / max(1, sourceVisible.width)
            let relY = (currentRect.minY - sourceVisible.minY) / max(1, sourceVisible.height)
            let relW = currentRect.width / max(1, sourceVisible.width)
            let relH = currentRect.height / max(1, sourceVisible.height)

            let newW = min(targetVisible.width, targetVisible.width * relW)
            let newH = min(targetVisible.height, targetVisible.height * relH)
            let newX = targetVisible.minX + (targetVisible.width * relX)
            let newY = targetVisible.minY + (targetVisible.height * relY)

            let newRect = CGRect(x: newX, y: newY, width: newW, height: newH)
            setWindowRect(windowElement, targetRect: newRect)
            playFeedback()
            return true
        }

        // Calculate target rect using SnapGeometry
        let visibleFrame = ScreenManager.shared.visibleQuartzFrame(for: currentScreen)
        let gap = UserSettings.shared.windowGap
        let targetRect = SnapGeometry.targetRect(for: effectiveAction, in: visibleFrame, currentWindowRect: currentRect, gap: gap)

        // Apply rect to window
        setWindowRect(windowElement, targetRect: targetRect)

        // Update cycle tracking
        self.lastAction = action
        self.lastActionTime = Date()
        self.lastTargetRect = targetRect

        playFeedback()
        return true
    }

    /// Snaps a specific window directly (used by drag-to-snap)
    public func snapWindow(_ windowElement: AXUIElement, to action: SnapAction, on screen: NSScreen) {
        guard let currentRect = getWindowRect(windowElement) else { return }

        // Find PID
        var pid: pid_t = 0
        AXUIElementGetPid(windowElement, &pid)
        if pid != 0 && windowRestoreFrames[pid] == nil {
            windowRestoreFrames[pid] = currentRect
        }

        let visibleFrame = ScreenManager.shared.visibleQuartzFrame(for: screen)
        let gap = UserSettings.shared.windowGap
        let targetRect = SnapGeometry.targetRect(for: action, in: visibleFrame, currentWindowRect: currentRect, gap: gap)

        setWindowRect(windowElement, targetRect: targetRect)
        playFeedback()
    }

    private func resolveCycleAction(for action: SnapAction, windowElement: AXUIElement) -> SnapAction {
        guard UserSettings.shared.cycleRepeatedPresses,
              let last = lastAction,
              let lastTime = lastActionTime,
              Date().timeIntervalSince(lastTime) < 1.3,
              action == last,
              let next = action.nextInCycle else {
            return action
        }

        // Check if the window is currently positioned at the last target rect
        if let currentRect = getWindowRect(windowElement),
           let lastTarget = lastTargetRect {
            let diffX = abs(currentRect.minX - lastTarget.minX)
            let diffY = abs(currentRect.minY - lastTarget.minY)
            let diffW = abs(currentRect.width - lastTarget.width)
            let diffH = abs(currentRect.height - lastTarget.height)
            if diffX < 25 && diffY < 25 && diffW < 25 && diffH < 25 {
                return next
            }
        }

        return action
    }

    public func getFrontmostWindow() -> (AXUIElement, AXUIElement, pid_t)? {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else { return nil }

        if let bundleId = frontApp.bundleIdentifier, UserSettings.shared.isAppIgnored(bundleIdentifier: bundleId) {
            return nil
        }

        let appPid = frontApp.processIdentifier
        let appElement = AXUIElementCreateApplication(appPid)

        var windowValue: AnyObject?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &windowValue)
        if result == .success, let win = windowValue {
            let windowElement = win as! AXUIElement
            return (appElement, windowElement, appPid)
        }

        // Fallback to main window
        var mainWindowValue: AnyObject?
        let mainResult = AXUIElementCopyAttributeValue(appElement, kAXMainWindowAttribute as CFString, &mainWindowValue)
        if mainResult == .success, let win = mainWindowValue {
            let windowElement = win as! AXUIElement
            return (appElement, windowElement, appPid)
        }

        return nil
    }

    public func getWindowUnderCursor(at quartzPoint: CGPoint) -> AXUIElement? {
        let systemWide = AXUIElementCreateSystemWide()
        var elementValue: AXUIElement?
        let result = AXUIElementCopyElementAtPosition(systemWide, Float(quartzPoint.x), Float(quartzPoint.y), &elementValue)
        guard result == .success, let element = elementValue else { return nil }

        // Climb up the accessibility tree until we find the window role
        var current: AXUIElement = element
        while true {
            var roleValue: AnyObject?
            if AXUIElementCopyAttributeValue(current, kAXRoleAttribute as CFString, &roleValue) == .success,
               let role = roleValue as? String {
                if role == kAXWindowRole as String {
                    return current
                }
            }

            var parentValue: AnyObject?
            if AXUIElementCopyAttributeValue(current, kAXParentAttribute as CFString, &parentValue) == .success,
               let parent = parentValue {
                current = (parent as! AXUIElement)
            } else {
                break
            }
        }
        return nil
    }

    public func getWindowRect(_ window: AXUIElement) -> CGRect? {
        var posValue: AnyObject?
        var sizeValue: AnyObject?

        guard AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &posValue) == .success,
              AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeValue) == .success else {
            return nil
        }

        var point = CGPoint.zero
        var size = CGSize.zero

        if let pVal = posValue as! AXValue? {
            AXValueGetValue(pVal, .cgPoint, &point)
        }
        if let sVal = sizeValue as! AXValue? {
            AXValueGetValue(sVal, .cgSize, &size)
        }

        return CGRect(origin: point, size: size)
    }

    public func setWindowRect(_ window: AXUIElement, targetRect: CGRect) {
        var pt = CGPoint(x: targetRect.origin.x, y: targetRect.origin.y)
        var sz = CGSize(width: targetRect.size.width, height: targetRect.size.height)

        let ptVal = AXValueCreate(.cgPoint, &pt)
        let szVal = AXValueCreate(.cgSize, &sz)

        // Setting size first then position then size again handles macOS constraint clamping smoothly
        if let s = szVal {
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, s)
        }
        if let p = ptVal {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, p)
        }
        if let s = szVal {
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, s)
        }
        if let p = ptVal {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, p)
        }
    }

    private func playFeedback() {
        if UserSettings.shared.playFeedbackSound {
            AudioServicesPlaySystemSound(1057) // Subtle tick sound
        }
    }
}
