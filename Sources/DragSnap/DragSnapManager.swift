import Cocoa
import ApplicationServices

public class DragSnapManager {
    public static let shared = DragSnapManager()

    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var candidateAction: SnapAction?
    private var candidateScreen: NSScreen?

    // Window drag tracking
    private var trackedWindow: AXUIElement?
    private var initialWindowOrigin: CGPoint?
    private var isRealWindowDrag = false
    private var dragStartPoint: NSPoint?

    private init() {}

    public func startMonitoring() {
        stopMonitoring()

        // A global event monitor installs an event tap, which makes macOS show the
        // "Device Control and Data Access" dialog if we are not yet trusted.
        // AccessibilityManager calls startMonitoring() again once permission is granted.
        guard AXIsProcessTrusted() else { return }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .leftMouseDragged, .leftMouseUp]
        ) { [weak self] event in
            self?.handleMouseEvent(event)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDown, .leftMouseDragged, .leftMouseUp]
        ) { [weak self] event in
            self?.handleMouseEvent(event)
            return event
        }
    }

    public func stopMonitoring() {
        if let g = globalMonitor {
            NSEvent.removeMonitor(g)
            globalMonitor = nil
        }
        if let l = localMonitor {
            NSEvent.removeMonitor(l)
            localMonitor = nil
        }
        resetDragState()
    }

    private func resetDragState() {
        if candidateAction != nil {
            candidateAction = nil
            candidateScreen = nil
            SnapPreviewOverlay.shared.hide()
        }
        trackedWindow = nil
        initialWindowOrigin = nil
        isRealWindowDrag = false
        dragStartPoint = nil
    }

    private func handleMouseEvent(_ event: NSEvent) {
        guard UserSettings.shared.isDragSnappingEnabled else {
            resetDragState()
            return
        }

        // Calling any AXUIElement API while untrusted makes macOS show the
        // "Device Control and Data Access" dialog unprompted. Only proceed when trusted.
        guard AXIsProcessTrusted() else {
            resetDragState()
            return
        }

        switch event.type {
        case .leftMouseDown:
            handleMouseDown()

        case .leftMouseDragged:
            handleDrag(mouseLocation: NSEvent.mouseLocation)

        case .leftMouseUp:
            handleMouseUp()

        default:
            break
        }
    }

    private func handleMouseDown() {
        dragStartPoint = NSEvent.mouseLocation
        isRealWindowDrag = false
        candidateAction = nil
        candidateScreen = nil

        // Find the window under the mouse
        let quartzPt = ScreenManager.shared.cocoaToQuartz(point: NSEvent.mouseLocation)
        if let win = WindowManager.shared.getWindowUnderCursor(at: quartzPt) {
            trackedWindow = win
            initialWindowOrigin = WindowManager.shared.getWindowRect(win)?.origin
        } else if let (_, win, _) = WindowManager.shared.getFrontmostWindow() {
            trackedWindow = win
            initialWindowOrigin = WindowManager.shared.getWindowRect(win)?.origin
        } else {
            trackedWindow = nil
            initialWindowOrigin = nil
        }
    }

    private func handleDrag(mouseLocation: NSPoint) {
        // Fallback initialization if leftMouseDown was missed
        if trackedWindow == nil {
            let quartzPt = ScreenManager.shared.cocoaToQuartz(point: mouseLocation)
            if let win = WindowManager.shared.getWindowUnderCursor(at: quartzPt) ?? WindowManager.shared.getFrontmostWindow()?.1 {
                trackedWindow = win
                initialWindowOrigin = WindowManager.shared.getWindowRect(win)?.origin
            }
        }

        // Verify that an actual window is moving before activating snap zones
        if !isRealWindowDrag {
            guard let win = trackedWindow, let initOrigin = initialWindowOrigin else {
                return
            }

            if let currentRect = WindowManager.shared.getWindowRect(win) {
                let dx = abs(currentRect.origin.x - initOrigin.x)
                let dy = abs(currentRect.origin.y - initOrigin.y)
                // Window must physically shift > 5 points to confirm the user is moving the window,
                // not selecting text or dragging UI items inside an app
                if dx > 5 || dy > 5 {
                    isRealWindowDrag = true
                } else {
                    return
                }
            } else {
                return
            }
        }

        let screen = ScreenManager.shared.screenContaining(cocoaPoint: mouseLocation)
        let sFrame = screen.frame

        // Distances from screen edges
        let distLeft = mouseLocation.x - sFrame.minX
        let distRight = sFrame.maxX - mouseLocation.x
        let distBottom = mouseLocation.y - sFrame.minY
        let distTop = sFrame.maxY - mouseLocation.y

        // Hysteresis:
        // Use a tighter threshold to enter a snap zone, and a wider threshold to stay in it.
        // This permanently eliminates boundary jitter and blinking.
        let isAlreadyActive = (candidateAction != nil)
        let edgeThreshold: CGFloat = isAlreadyActive ? 36.0 : 18.0
        let cornerThreshold: CGFloat = isAlreadyActive ? 95.0 : 75.0

        var detected: SnapAction?

        // 1. Corners
        if (distTop <= edgeThreshold && distLeft <= cornerThreshold) ||
           (distLeft <= edgeThreshold && distTop <= cornerThreshold) {
            detected = .topLeft
        } else if (distTop <= edgeThreshold && distRight <= cornerThreshold) ||
                  (distRight <= edgeThreshold && distTop <= cornerThreshold) {
            detected = .topRight
        } else if (distBottom <= edgeThreshold && distLeft <= cornerThreshold) ||
                  (distLeft <= edgeThreshold && distBottom <= cornerThreshold) {
            detected = .bottomLeft
        } else if (distBottom <= edgeThreshold && distRight <= cornerThreshold) ||
                  (distRight <= edgeThreshold && distBottom <= cornerThreshold) {
            detected = .bottomRight
        }
        // 2. Edges
        else if distTop <= edgeThreshold {
            detected = .maximize
        } else if distLeft <= edgeThreshold {
            detected = .left
        } else if distRight <= edgeThreshold {
            detected = .right
        } else if distBottom <= edgeThreshold {
            detected = .bottom
        }

        // Verify if action is enabled in user settings
        if let action = detected, UserSettings.shared.isDragTriggerEnabled(for: action) {
            if candidateAction != action || candidateScreen != screen {
                candidateAction = action
                candidateScreen = screen

                let visible = ScreenManager.shared.visibleQuartzFrame(for: screen)
                let gap = UserSettings.shared.windowGap
                let target = SnapGeometry.targetRect(for: action, in: visible, gap: gap)
                SnapPreviewOverlay.shared.show(targetQuartzRect: target, on: screen)
            }
        } else {
            if candidateAction != nil {
                candidateAction = nil
                candidateScreen = nil
                SnapPreviewOverlay.shared.hide()
            }
        }
    }

    private func handleMouseUp() {
        guard isRealWindowDrag, let action = candidateAction, let screen = candidateScreen else {
            resetDragState()
            return
        }

        // Reset overlay
        SnapPreviewOverlay.shared.hide()
        let targetWindow = trackedWindow

        resetDragState()

        // Snap the window that was being dragged
        if let win = targetWindow {
            WindowManager.shared.snapWindow(win, to: action, on: screen)
        } else if let (_, windowElement, _) = WindowManager.shared.getFrontmostWindow() {
            WindowManager.shared.snapWindow(windowElement, to: action, on: screen)
        }
    }
}

