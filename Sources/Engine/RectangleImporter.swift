import Cocoa
import Carbon

public class RectangleImporter {
    public static let shared = RectangleImporter()

    private init() {}

    /// Checks if Rectangle preferences exist on this machine
    public var isRectangleInstalled: Bool {
        guard let defaults = UserDefaults(suiteName: "com.knollsoft.Rectangle") else { return false }
        return defaults.object(forKey: "SUHasLaunchedBefore") != nil ||
               defaults.object(forKey: "leftHalf") != nil ||
               defaults.object(forKey: "alternateDefaultShortcuts") != nil
    }

    /// Converts Cocoa modifierFlags to Carbon modifiers
    public static func cocoaModifiersToCarbon(_ cocoa: UInt) -> UInt32 {
        var carbon: UInt32 = 0
        if (cocoa & NSEvent.ModifierFlags.command.rawValue) != 0 { carbon |= UInt32(cmdKey) }
        if (cocoa & NSEvent.ModifierFlags.option.rawValue) != 0 { carbon |= UInt32(optionKey) }
        if (cocoa & NSEvent.ModifierFlags.control.rawValue) != 0 { carbon |= UInt32(controlKey) }
        if (cocoa & NSEvent.ModifierFlags.shift.rawValue) != 0 { carbon |= UInt32(shiftKey) }
        return carbon
    }

    /// Imports all shortcuts from Rectangle preferences and defaults
    public func importShortcuts() -> [SnapAction: KeyCombination] {
        var result = defaultRectangleShortcuts()

        guard let defaults = UserDefaults(suiteName: "com.knollsoft.Rectangle") else {
            return result
        }

        let mapping: [String: SnapAction] = [
            "leftHalf": .left,
            "rightHalf": .right,
            "topHalf": .top,
            "bottomHalf": .bottom,
            "topLeft": .topLeft,
            "topRight": .topRight,
            "bottomLeft": .bottomLeft,
            "bottomRight": .bottomRight,
            "maximize": .maximize,
            "almostMaximize": .almostMaximize,
            "maximizeHeight": .maximizeHeight,
            "firstThird": .leftThird,
            "centerThird": .centerThird,
            "lastThird": .rightThird,
            "firstTwoThirds": .leftTwoThirds,
            "centerTwoThirds": .centerTwoThirds,
            "lastTwoThirds": .rightTwoThirds,
            "center": .center,
            "restore": .restore,
            "makeLarger": .larger,
            "makeSmaller": .smaller,
            "nextDisplay": .nextDisplay,
            "previousDisplay": .previousDisplay,
            "moveLeft": .moveLeft,
            "moveRight": .moveRight,
            "moveUp": .moveUp,
            "moveDown": .moveDown,
            "firstFourth": .firstFourth,
            "secondFourth": .secondFourth,
            "thirdFourth": .thirdFourth,
            "lastFourth": .fourthFourth,
            "topLeftSixth": .topLeftSixth,
            "topCenterSixth": .topCenterSixth,
            "topRightSixth": .topRightSixth,
            "bottomLeftSixth": .bottomLeftSixth,
            "bottomCenterSixth": .bottomCenterSixth,
            "bottomRightSixth": .bottomRightSixth
        ]

        for (rectKey, action) in mapping {
            if let dict = defaults.dictionary(forKey: rectKey),
               let keyCode = dict["keyCode"] as? Int,
               let modFlags = dict["modifierFlags"] as? UInt {
                let carbonMods = RectangleImporter.cocoaModifiersToCarbon(modFlags)
                result[action] = KeyCombination(keyCode: UInt32(keyCode), carbonModifiers: carbonMods)
            }
        }

        // Bottom Right is Control + Command + Down Arrow (kVK_DownArrow = 125)
        let ctrlCmd = UInt32(controlKey | cmdKey)
        result[.bottomRight] = KeyCombination(keyCode: UInt32(kVK_DownArrow), carbonModifiers: ctrlCmd)

        return result
    }

    /// Standard Rectangle (Alternate) default shortcuts matching the user's configuration
    public func defaultRectangleShortcuts() -> [SnapAction: KeyCombination] {
        let optCmd = UInt32(optionKey | cmdKey)
        let ctrlCmd = UInt32(controlKey | cmdKey)
        let ctrlOpt = UInt32(controlKey | optionKey)
        let ctrlOptShift = UInt32(controlKey | optionKey | shiftKey)
        let ctrlOptCmd = UInt32(controlKey | optionKey | cmdKey)

        var map: [SnapAction: KeyCombination] = [:]

        // Halves: Option + Command + Arrows
        map[.left] = KeyCombination(keyCode: UInt32(kVK_LeftArrow), carbonModifiers: optCmd)
        map[.right] = KeyCombination(keyCode: UInt32(kVK_RightArrow), carbonModifiers: optCmd)
        map[.top] = KeyCombination(keyCode: UInt32(kVK_UpArrow), carbonModifiers: optCmd)
        map[.bottom] = KeyCombination(keyCode: UInt32(kVK_DownArrow), carbonModifiers: optCmd)

        // Corners: Control + Command + Arrows
        map[.topLeft] = KeyCombination(keyCode: UInt32(kVK_UpArrow), carbonModifiers: ctrlCmd)
        map[.topRight] = KeyCombination(keyCode: UInt32(kVK_RightArrow), carbonModifiers: ctrlCmd)
        map[.bottomLeft] = KeyCombination(keyCode: UInt32(kVK_LeftArrow), carbonModifiers: ctrlCmd)
        map[.bottomRight] = KeyCombination(keyCode: UInt32(kVK_DownArrow), carbonModifiers: ctrlCmd)

        // Thirds: Control + Option + D, F, G
        map[.leftThird] = KeyCombination(keyCode: UInt32(kVK_ANSI_D), carbonModifiers: ctrlOpt)
        map[.centerThird] = KeyCombination(keyCode: UInt32(kVK_ANSI_F), carbonModifiers: ctrlOpt)
        map[.rightThird] = KeyCombination(keyCode: UInt32(kVK_ANSI_G), carbonModifiers: ctrlOpt)

        // Two Thirds: Control + Option + E, R, T
        map[.leftTwoThirds] = KeyCombination(keyCode: UInt32(kVK_ANSI_E), carbonModifiers: ctrlOpt)
        map[.centerTwoThirds] = KeyCombination(keyCode: UInt32(kVK_ANSI_R), carbonModifiers: ctrlOpt)
        map[.rightTwoThirds] = KeyCombination(keyCode: UInt32(kVK_ANSI_T), carbonModifiers: ctrlOpt)

        // Maximize & Sizing
        map[.maximize] = KeyCombination(keyCode: UInt32(kVK_ANSI_F), carbonModifiers: optCmd)
        map[.almostMaximize] = KeyCombination(keyCode: UInt32(kVK_ANSI_F), carbonModifiers: UInt32(optionKey | cmdKey | shiftKey))
        map[.maximizeHeight] = KeyCombination(keyCode: UInt32(kVK_UpArrow), carbonModifiers: ctrlOptShift)
        map[.larger] = KeyCombination(keyCode: UInt32(kVK_ANSI_Equal), carbonModifiers: ctrlOpt)
        map[.smaller] = KeyCombination(keyCode: UInt32(kVK_ANSI_Minus), carbonModifiers: ctrlOpt)
        map[.center] = KeyCombination(keyCode: UInt32(kVK_ANSI_C), carbonModifiers: ctrlOpt)
        map[.restore] = KeyCombination(keyCode: UInt32(kVK_Delete), carbonModifiers: ctrlOpt)

        // Displays
        map[.nextDisplay] = KeyCombination(keyCode: UInt32(kVK_RightArrow), carbonModifiers: ctrlOptCmd)
        map[.previousDisplay] = KeyCombination(keyCode: UInt32(kVK_LeftArrow), carbonModifiers: ctrlOptCmd)

        // Move to Edge
        map[.moveLeft] = KeyCombination(keyCode: UInt32(kVK_LeftArrow), carbonModifiers: ctrlOptCmd)
        map[.moveRight] = KeyCombination(keyCode: UInt32(kVK_RightArrow), carbonModifiers: ctrlOptCmd)
        map[.moveUp] = KeyCombination(keyCode: UInt32(kVK_UpArrow), carbonModifiers: ctrlOptCmd)
        map[.moveDown] = KeyCombination(keyCode: UInt32(kVK_DownArrow), carbonModifiers: ctrlOptCmd)

        return map
    }

    /// Standard Magnet default shortcuts
    public func defaultMagnetShortcuts() -> [SnapAction: KeyCombination] {
        var map: [SnapAction: KeyCombination] = [:]
        for action in SnapAction.allCases {
            map[action] = action.magnetDefaultKeyCombination
        }
        return map
    }
}
