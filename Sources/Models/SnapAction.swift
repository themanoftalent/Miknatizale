import Foundation
import Carbon
import CoreGraphics

public enum SnapAction: String, CaseIterable, Identifiable, Codable {
    // Halves
    case left = "left"
    case right = "right"
    case top = "top"
    case bottom = "bottom"

    // Corners
    case topLeft = "topLeft"
    case topRight = "topRight"
    case bottomLeft = "bottomLeft"
    case bottomRight = "bottomRight"

    // Thirds
    case leftThird = "leftThird"
    case centerThird = "centerThird"
    case rightThird = "rightThird"

    // Two Thirds
    case leftTwoThirds = "leftTwoThirds"
    case centerTwoThirds = "centerTwoThirds"
    case rightTwoThirds = "rightTwoThirds"

    // Sizing & Maximize
    case maximize = "maximize"
    case almostMaximize = "almostMaximize"
    case maximizeHeight = "maximizeHeight"
    case larger = "larger"
    case smaller = "smaller"
    case center = "center"
    case restore = "restore"

    // Move to Edge
    case moveLeft = "moveLeft"
    case moveRight = "moveRight"
    case moveUp = "moveUp"
    case moveDown = "moveDown"

    // Fourths
    case firstFourth = "firstFourth"
    case secondFourth = "secondFourth"
    case thirdFourth = "thirdFourth"
    case fourthFourth = "fourthFourth"

    // Sixths
    case topLeftSixth = "topLeftSixth"
    case topCenterSixth = "topCenterSixth"
    case topRightSixth = "topRightSixth"
    case bottomLeftSixth = "bottomLeftSixth"
    case bottomCenterSixth = "bottomCenterSixth"
    case bottomRightSixth = "bottomRightSixth"

    // Displays
    case nextDisplay = "nextDisplay"
    case previousDisplay = "previousDisplay"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .left: return "Left"
        case .right: return "Right"
        case .top: return "Top"
        case .bottom: return "Bottom"
        case .topLeft: return "Top Left"
        case .topRight: return "Top Right"
        case .bottomLeft: return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        case .leftThird: return "First Third"
        case .centerThird: return "Center Third"
        case .rightThird: return "Last Third"
        case .leftTwoThirds: return "First Two Thirds"
        case .centerTwoThirds: return "Center Two Thirds"
        case .rightTwoThirds: return "Last Two Thirds"
        case .maximize: return "Maximize"
        case .almostMaximize: return "Almost Maximize"
        case .maximizeHeight: return "Maximize Height"
        case .larger: return "Larger"
        case .smaller: return "Smaller"
        case .center: return "Move to Center"
        case .restore: return "Restore"
        case .moveLeft: return "Move Left"
        case .moveRight: return "Move Right"
        case .moveUp: return "Move Up"
        case .moveDown: return "Move Down"
        case .firstFourth: return "First Fourth"
        case .secondFourth: return "Second Fourth"
        case .thirdFourth: return "Third Fourth"
        case .fourthFourth: return "Last Fourth"
        case .topLeftSixth: return "Top Left Sixth"
        case .topCenterSixth: return "Top Center Sixth"
        case .topRightSixth: return "Top Right Sixth"
        case .bottomLeftSixth: return "Bottom Left Sixth"
        case .bottomCenterSixth: return "Bottom Center Sixth"
        case .bottomRightSixth: return "Bottom Right Sixth"
        case .nextDisplay: return "Next Display"
        case .previousDisplay: return "Previous Display"
        }
    }

    public var category: SnapCategory {
        switch self {
        case .left, .right, .top, .bottom:
            return .horizontal
        case .topLeft, .topRight, .bottomLeft, .bottomRight:
            return .corners
        case .leftThird, .centerThird, .rightThird,
             .leftTwoThirds, .centerTwoThirds, .rightTwoThirds:
            return .thirds
        case .maximize, .almostMaximize, .maximizeHeight, .larger, .smaller, .center, .restore:
            return .sizeAndPosition
        case .moveLeft, .moveRight, .moveUp, .moveDown:
            return .moveToEdge
        case .firstFourth, .secondFourth, .thirdFourth, .fourthFourth:
            return .fourths
        case .topLeftSixth, .topCenterSixth, .topRightSixth,
             .bottomLeftSixth, .bottomCenterSixth, .bottomRightSixth:
            return .sixths
        case .nextDisplay, .previousDisplay:
            return .displays
        }
    }

    /// Inherits Rectangle's default key combinations
    public var defaultKeyCombination: KeyCombination {
        let optCmd = UInt32(optionKey | cmdKey)
        let ctrlCmd = UInt32(controlKey | cmdKey)
        let ctrlOpt = UInt32(controlKey | optionKey)
        let ctrlOptShift = UInt32(controlKey | optionKey | shiftKey)
        let ctrlOptCmd = UInt32(controlKey | optionKey | cmdKey)

        switch self {
        case .left:
            return KeyCombination(keyCode: UInt32(kVK_LeftArrow), carbonModifiers: optCmd)
        case .right:
            return KeyCombination(keyCode: UInt32(kVK_RightArrow), carbonModifiers: optCmd)
        case .top:
            return KeyCombination(keyCode: UInt32(kVK_UpArrow), carbonModifiers: optCmd)
        case .bottom:
            return KeyCombination(keyCode: UInt32(kVK_DownArrow), carbonModifiers: optCmd)
        case .topLeft:
            return KeyCombination(keyCode: UInt32(kVK_UpArrow), carbonModifiers: ctrlCmd)
        case .topRight:
            return KeyCombination(keyCode: UInt32(kVK_RightArrow), carbonModifiers: ctrlCmd)
        case .bottomLeft:
            return KeyCombination(keyCode: UInt32(kVK_LeftArrow), carbonModifiers: ctrlCmd)
        case .bottomRight:
            return KeyCombination(keyCode: UInt32(kVK_DownArrow), carbonModifiers: ctrlCmd)
        case .leftThird:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_D), carbonModifiers: ctrlOpt)
        case .centerThird:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_F), carbonModifiers: ctrlOpt)
        case .rightThird:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_G), carbonModifiers: ctrlOpt)
        case .leftTwoThirds:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_E), carbonModifiers: ctrlOpt)
        case .centerTwoThirds:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_R), carbonModifiers: ctrlOpt)
        case .rightTwoThirds:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_T), carbonModifiers: ctrlOpt)
        case .maximize:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_F), carbonModifiers: optCmd)
        case .almostMaximize:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_F), carbonModifiers: UInt32(optionKey | cmdKey | shiftKey))
        case .maximizeHeight:
            return KeyCombination(keyCode: UInt32(kVK_UpArrow), carbonModifiers: ctrlOptShift)
        case .larger:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_Equal), carbonModifiers: ctrlOpt)
        case .smaller:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_Minus), carbonModifiers: ctrlOpt)
        case .center:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_C), carbonModifiers: ctrlOpt)
        case .restore:
            return KeyCombination(keyCode: UInt32(kVK_Delete), carbonModifiers: ctrlOpt)
        case .nextDisplay:
            return KeyCombination(keyCode: UInt32(kVK_RightArrow), carbonModifiers: ctrlOptCmd)
        case .previousDisplay:
            return KeyCombination(keyCode: UInt32(kVK_LeftArrow), carbonModifiers: ctrlOptCmd)
        case .moveLeft:
            return KeyCombination(keyCode: UInt32(kVK_LeftArrow), carbonModifiers: ctrlOptCmd)
        case .moveRight:
            return KeyCombination(keyCode: UInt32(kVK_RightArrow), carbonModifiers: ctrlOptCmd)
        case .moveUp:
            return KeyCombination(keyCode: UInt32(kVK_UpArrow), carbonModifiers: ctrlOptCmd)
        case .moveDown:
            return KeyCombination(keyCode: UInt32(kVK_DownArrow), carbonModifiers: ctrlOptCmd)
        case .firstFourth:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_1), carbonModifiers: ctrlOpt)
        case .secondFourth:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_2), carbonModifiers: ctrlOpt)
        case .thirdFourth:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_3), carbonModifiers: ctrlOpt)
        case .fourthFourth:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_4), carbonModifiers: ctrlOpt)
        case .topLeftSixth:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_7), carbonModifiers: ctrlOpt)
        case .topCenterSixth:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_8), carbonModifiers: ctrlOpt)
        case .topRightSixth:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_9), carbonModifiers: ctrlOpt)
        case .bottomLeftSixth:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_U), carbonModifiers: ctrlOptShift)
        case .bottomCenterSixth:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_I), carbonModifiers: ctrlOptShift)
        case .bottomRightSixth:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_O), carbonModifiers: ctrlOptShift)
        }
    }

    /// Classic Magnet default hotkey mapping
    public var magnetDefaultKeyCombination: KeyCombination {
        let ctrlOpt = UInt32(controlKey | optionKey)
        let ctrlOptShift = UInt32(controlKey | optionKey | shiftKey)
        let ctrlOptCmd = UInt32(controlKey | optionKey | cmdKey)

        switch self {
        case .left:
            return KeyCombination(keyCode: UInt32(kVK_LeftArrow), carbonModifiers: ctrlOpt)
        case .right:
            return KeyCombination(keyCode: UInt32(kVK_RightArrow), carbonModifiers: ctrlOpt)
        case .top:
            return KeyCombination(keyCode: UInt32(kVK_UpArrow), carbonModifiers: ctrlOpt)
        case .bottom:
            return KeyCombination(keyCode: UInt32(kVK_DownArrow), carbonModifiers: ctrlOpt)
        case .topLeft:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_U), carbonModifiers: ctrlOpt)
        case .topRight:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_I), carbonModifiers: ctrlOpt)
        case .bottomLeft:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_J), carbonModifiers: ctrlOpt)
        case .bottomRight:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_K), carbonModifiers: ctrlOpt)
        case .leftThird:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_D), carbonModifiers: ctrlOpt)
        case .centerThird:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_F), carbonModifiers: ctrlOpt)
        case .rightThird:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_G), carbonModifiers: ctrlOpt)
        case .leftTwoThirds:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_E), carbonModifiers: ctrlOpt)
        case .centerTwoThirds:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_R), carbonModifiers: ctrlOpt)
        case .rightTwoThirds:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_T), carbonModifiers: ctrlOpt)
        case .maximize:
            return KeyCombination(keyCode: UInt32(kVK_Return), carbonModifiers: ctrlOpt)
        case .almostMaximize:
            return KeyCombination(keyCode: UInt32(kVK_Return), carbonModifiers: ctrlOptShift)
        case .maximizeHeight:
            return KeyCombination(keyCode: UInt32(kVK_UpArrow), carbonModifiers: ctrlOptShift)
        case .larger:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_Equal), carbonModifiers: ctrlOpt)
        case .smaller:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_Minus), carbonModifiers: ctrlOpt)
        case .center:
            return KeyCombination(keyCode: UInt32(kVK_ANSI_C), carbonModifiers: ctrlOpt)
        case .restore:
            return KeyCombination(keyCode: UInt32(kVK_Delete), carbonModifiers: ctrlOpt)
        case .nextDisplay:
            return KeyCombination(keyCode: UInt32(kVK_RightArrow), carbonModifiers: ctrlOptCmd)
        case .previousDisplay:
            return KeyCombination(keyCode: UInt32(kVK_LeftArrow), carbonModifiers: ctrlOptCmd)
        default:
            return defaultKeyCombination
        }
    }

    /// Normalized rectangle `[0, 1]` for preview grid and window calculation
    public var normalizedRect: CGRect {
        switch self {
        case .left:
            return CGRect(x: 0.0, y: 0.0, width: 0.5, height: 1.0)
        case .right:
            return CGRect(x: 0.5, y: 0.0, width: 0.5, height: 1.0)
        case .top:
            return CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.5)
        case .bottom:
            return CGRect(x: 0.0, y: 0.5, width: 1.0, height: 0.5)
        case .topLeft:
            return CGRect(x: 0.0, y: 0.0, width: 0.5, height: 0.5)
        case .topRight:
            return CGRect(x: 0.5, y: 0.0, width: 0.5, height: 0.5)
        case .bottomLeft:
            return CGRect(x: 0.0, y: 0.5, width: 0.5, height: 0.5)
        case .bottomRight:
            return CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)
        case .leftThird:
            return CGRect(x: 0.0, y: 0.0, width: 1.0 / 3.0, height: 1.0)
        case .centerThird:
            return CGRect(x: 1.0 / 3.0, y: 0.0, width: 1.0 / 3.0, height: 1.0)
        case .rightThird:
            return CGRect(x: 2.0 / 3.0, y: 0.0, width: 1.0 / 3.0, height: 1.0)
        case .leftTwoThirds:
            return CGRect(x: 0.0, y: 0.0, width: 2.0 / 3.0, height: 1.0)
        case .centerTwoThirds:
            return CGRect(x: 1.0 / 6.0, y: 0.0, width: 2.0 / 3.0, height: 1.0)
        case .rightTwoThirds:
            return CGRect(x: 1.0 / 3.0, y: 0.0, width: 2.0 / 3.0, height: 1.0)
        case .maximize:
            return CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        case .almostMaximize:
            return CGRect(x: 0.05, y: 0.05, width: 0.9, height: 0.9)
        case .maximizeHeight:
            return CGRect(x: 0.25, y: 0.0, width: 0.5, height: 1.0)
        case .larger:
            return CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
        case .smaller:
            return CGRect(x: 0.3, y: 0.3, width: 0.4, height: 0.4)
        case .center:
            return CGRect(x: 0.15, y: 0.15, width: 0.7, height: 0.7)
        case .moveLeft:
            return CGRect(x: 0.0, y: 0.25, width: 0.4, height: 0.5)
        case .moveRight:
            return CGRect(x: 0.6, y: 0.25, width: 0.4, height: 0.5)
        case .moveUp:
            return CGRect(x: 0.25, y: 0.0, width: 0.5, height: 0.4)
        case .moveDown:
            return CGRect(x: 0.25, y: 0.6, width: 0.5, height: 0.4)
        case .firstFourth:
            return CGRect(x: 0.0, y: 0.0, width: 0.25, height: 1.0)
        case .secondFourth:
            return CGRect(x: 0.25, y: 0.0, width: 0.25, height: 1.0)
        case .thirdFourth:
            return CGRect(x: 0.5, y: 0.0, width: 0.25, height: 1.0)
        case .fourthFourth:
            return CGRect(x: 0.75, y: 0.0, width: 0.25, height: 1.0)
        case .topLeftSixth:
            return CGRect(x: 0.0, y: 0.0, width: 1.0 / 3.0, height: 0.5)
        case .topCenterSixth:
            return CGRect(x: 1.0 / 3.0, y: 0.0, width: 1.0 / 3.0, height: 0.5)
        case .topRightSixth:
            return CGRect(x: 2.0 / 3.0, y: 0.0, width: 1.0 / 3.0, height: 0.5)
        case .bottomLeftSixth:
            return CGRect(x: 0.0, y: 0.5, width: 1.0 / 3.0, height: 0.5)
        case .bottomCenterSixth:
            return CGRect(x: 1.0 / 3.0, y: 0.5, width: 1.0 / 3.0, height: 0.5)
        case .bottomRightSixth:
            return CGRect(x: 2.0 / 3.0, y: 0.5, width: 1.0 / 3.0, height: 0.5)
        case .restore, .nextDisplay, .previousDisplay:
            return CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
    }

    /// Next action in consecutive key-press cycle
    public var nextInCycle: SnapAction? {
        switch self {
        case .left: return .leftThird
        case .leftThird: return .leftTwoThirds
        case .leftTwoThirds: return .left

        case .right: return .rightThird
        case .rightThird: return .rightTwoThirds
        case .rightTwoThirds: return .right

        case .top: return .maximize
        case .maximize: return .almostMaximize
        case .almostMaximize: return .maximize

        case .firstFourth: return .secondFourth
        case .secondFourth: return .thirdFourth
        case .thirdFourth: return .fourthFourth
        case .fourthFourth: return .firstFourth

        default: return nil
        }
    }

    public var supportsDragActivation: Bool {
        switch self {
        case .left, .right, .top, .bottom,
             .topLeft, .topRight, .bottomLeft, .bottomRight,
             .maximize:
            return true
        default:
            return false
        }
    }

    public var triggerAreaDescription: String {
        switch self {
        case .left:
            return "Drag a window to the left edge of the display."
        case .right:
            return "Drag a window to the right edge of the display."
        case .top:
            return "Drag a window to the top edge of the display."
        case .bottom:
            return "Drag a window to the bottom edge of the display."
        case .topLeft:
            return "Drag a window to the top-left corner of the display."
        case .topRight:
            return "Drag a window to the top-right corner of the display."
        case .bottomLeft:
            return "Drag a window to the bottom-left corner of the display."
        case .bottomRight:
            return "Drag a window to the bottom-right corner of the display."
        case .maximize:
            return "Drag a window all the way to the top edge of the display."
        default:
            return "Not triggered by dragging."
        }
    }

    public var systemIcon: String {
        switch self {
        case .left: return "rectangle.lefthalf.filled"
        case .right: return "rectangle.righthalf.filled"
        case .top: return "rectangle.tophalf.filled"
        case .bottom: return "rectangle.bottomhalf.filled"
        case .topLeft: return "rectangle.inset.topleft.filled"
        case .topRight: return "rectangle.inset.topright.filled"
        case .bottomLeft: return "rectangle.inset.bottomleft.filled"
        case .bottomRight: return "rectangle.inset.bottomright.filled"
        case .leftThird, .centerThird, .rightThird: return "rectangle.split.3x1"
        case .leftTwoThirds, .centerTwoThirds, .rightTwoThirds: return "rectangle.split.3x1.fill"
        case .maximize: return "rectangle.fill"
        case .almostMaximize: return "rectangle"
        case .maximizeHeight: return "arrow.up.and.down.square.fill"
        case .larger: return "plus.square.fill"
        case .smaller: return "minus.square.fill"
        case .center: return "dot.scope"
        case .restore: return "arrow.uturn.backward"
        case .moveLeft: return "arrow.left.to.line"
        case .moveRight: return "arrow.right.to.line"
        case .moveUp: return "arrow.up.to.line"
        case .moveDown: return "arrow.down.to.line"
        case .firstFourth, .secondFourth, .thirdFourth, .fourthFourth: return "square.grid.2x2"
        case .topLeftSixth, .topCenterSixth, .topRightSixth,
             .bottomLeftSixth, .bottomCenterSixth, .bottomRightSixth: return "square.grid.3x2"
        case .nextDisplay: return "display.2"
        case .previousDisplay: return "display"
        }
    }
}
