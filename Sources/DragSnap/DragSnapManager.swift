import Cocoa
import ApplicationServices

public class DragSnapManager {
    public static let shared = DragSnapManager()

    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var candidateAction: SnapAction?
    private var candidateScreen: NSScreen?
    private var activeDraggedWindow: AXUIElement?

    private init() {}

    public func startMonitoring() {
        stopMonitoring()

        globalMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDragged, .leftMouseUp]
        ) { [weak self] event in
            self?.handleMouseEvent(event)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDragged, .leftMouseUp]
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
    }

    private func handleMouseEvent(_ event: NSEvent) {
        guard UserSettings.shared.isDragSnappingEnabled else {
            if candidateAction != nil {
                candidateAction = nil
                SnapPreviewOverlay.shared.hide()
            }
            return
        }

        switch event.type {
        case .leftMouseDragged:
            handleDrag(mouseLocation: NSEvent.mouseLocation)

        case .leftMouseUp:
            handleMouseUp()

        default:
            break
        }
    }

    private func handleDrag(mouseLocation: NSPoint) {
        let screen = ScreenManager.shared.screenContaining(cocoaPoint: mouseLocation)
        let sFrame = screen.frame

        // Distances from screen edges
        let distLeft = mouseLocation.x - sFrame.minX
        let distRight = sFrame.maxX - mouseLocation.x
        let distBottom = mouseLocation.y - sFrame.minY
        let distTop = sFrame.maxY - mouseLocation.y

        let edgeThreshold: CGFloat = 20.0
        let cornerThreshold: CGFloat = 85.0

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
        guard let action = candidateAction, let screen = candidateScreen else {
            SnapPreviewOverlay.shared.hide()
            return
        }

        // Reset overlay
        SnapPreviewOverlay.shared.hide()
        candidateAction = nil
        candidateScreen = nil

        // Find frontmost window to snap
        if let (_, windowElement, _) = WindowManager.shared.getFrontmostWindow() {
            WindowManager.shared.snapWindow(windowElement, to: action, on: screen)
        }
    }
}
