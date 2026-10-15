import Cocoa

public class ScreenManager {
    public static let shared = ScreenManager()

    public var primaryScreenHeight: CGFloat {
        return NSScreen.screens.first?.frame.height ?? 900
    }

    /// Converts Cocoa NSRect (origin at bottom-left) to Quartz CGRect (origin at top-left)
    public func cocoaToQuartz(rect: NSRect) -> CGRect {
        let pHeight = primaryScreenHeight
        let quartzY = pHeight - (rect.origin.y + rect.height)
        return CGRect(x: rect.origin.x, y: quartzY, width: rect.width, height: rect.height)
    }

    /// Converts Quartz CGRect to Cocoa NSRect
    public func quartzToCocoa(rect: CGRect) -> NSRect {
        let pHeight = primaryScreenHeight
        let cocoaY = pHeight - (rect.origin.y + rect.height)
        return NSRect(x: rect.origin.x, y: cocoaY, width: rect.width, height: rect.height)
    }

    /// Converts Cocoa NSPoint to Quartz CGPoint
    public func cocoaToQuartz(point: NSPoint) -> CGPoint {
        let pHeight = primaryScreenHeight
        return CGPoint(x: point.x, y: pHeight - point.y)
    }

    /// Converts Quartz CGPoint to Cocoa NSPoint
    public func quartzToCocoa(point: CGPoint) -> NSPoint {
        let pHeight = primaryScreenHeight
        return NSPoint(x: point.x, y: pHeight - point.y)
    }

    /// Returns the usable visible frame of the screen in Quartz coordinates (accounting for Dock and Menu Bar)
    public func visibleQuartzFrame(for screen: NSScreen) -> CGRect {
        return cocoaToQuartz(rect: screen.visibleFrame)
    }

    /// Returns the total frame of the screen in Quartz coordinates
    public func totalQuartzFrame(for screen: NSScreen) -> CGRect {
        return cocoaToQuartz(rect: screen.frame)
    }

    /// Finds the screen containing the specified Quartz point
    public func screenContaining(quartzPoint: CGPoint) -> NSScreen {
        let cocoaPoint = quartzToCocoa(point: quartzPoint)
        for screen in NSScreen.screens {
            if NSPointInRect(cocoaPoint, screen.frame) {
                return screen
            }
        }
        return NSScreen.main ?? NSScreen.screens.first ?? NSScreen()
    }

    /// Finds the screen containing the specified Cocoa point
    public func screenContaining(cocoaPoint: NSPoint) -> NSScreen {
        for screen in NSScreen.screens {
            if NSPointInRect(cocoaPoint, screen.frame) {
                return screen
            }
        }
        return NSScreen.main ?? NSScreen.screens.first ?? NSScreen()
    }

    /// Finds the screen having the largest intersection with the specified Quartz window rect
    public func screenFor(windowQuartzRect: CGRect) -> NSScreen {
        let windowCocoaRect = quartzToCocoa(rect: windowQuartzRect)
        var bestScreen: NSScreen?
        var maxIntersectionArea: CGFloat = -1

        for screen in NSScreen.screens {
            let intersection = screen.frame.intersection(windowCocoaRect)
            if !intersection.isNull && !intersection.isEmpty {
                let area = intersection.width * intersection.height
                if area > maxIntersectionArea {
                    maxIntersectionArea = area
                    bestScreen = screen
                }
            }
        }

        if let best = bestScreen {
            return best
        }
        return NSScreen.main ?? NSScreen.screens.first ?? NSScreen()
    }

    /// Next display in multi-monitor setups
    public func nextScreen(from screen: NSScreen) -> NSScreen {
        let screens = NSScreen.screens
        guard screens.count > 1, let index = screens.firstIndex(of: screen) else {
            return screen
        }
        let nextIndex = (index + 1) % screens.count
        return screens[nextIndex]
    }

    /// Previous display in multi-monitor setups
    public func previousScreen(from screen: NSScreen) -> NSScreen {
        let screens = NSScreen.screens
        guard screens.count > 1, let index = screens.firstIndex(of: screen) else {
            return screen
        }
        let prevIndex = (index - 1 + screens.count) % screens.count
        return screens[prevIndex]
    }
}
