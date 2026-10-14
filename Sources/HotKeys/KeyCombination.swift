import Foundation
import Carbon

public struct KeyCombination: Codable, Equatable, Hashable {
    public var keyCode: UInt32
    public var carbonModifiers: UInt32

    public init(keyCode: UInt32, carbonModifiers: UInt32) {
        self.keyCode = keyCode
        self.carbonModifiers = carbonModifiers
    }

    public var isControl: Bool { (carbonModifiers & UInt32(controlKey)) != 0 }
    public var isOption: Bool { (carbonModifiers & UInt32(optionKey)) != 0 }
    public var isShift: Bool { (carbonModifiers & UInt32(shiftKey)) != 0 }
    public var isCommand: Bool { (carbonModifiers & UInt32(cmdKey)) != 0 }

    public var displayString: String {
        var str = ""
        if isControl { str += "⌃" }
        if isOption { str += "⌥" }
        if isShift { str += "⇧" }
        if isCommand { str += "⌘" }
        str += keyName
        return str
    }

    public var modifierSymbols: [String] {
        var symbols: [String] = []
        if isControl { symbols.append("⌃") }
        if isOption { symbols.append("⌥") }
        if isShift { symbols.append("⇧") }
        if isCommand { symbols.append("⌘") }
        return symbols
    }

    public var keyName: String {
        switch Int(keyCode) {
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        case kVK_Return: return "↩"
        case kVK_Delete: return "⌫"
        case kVK_Space: return "Space"
        case kVK_Escape: return "Esc"
        case kVK_Tab: return "⇥"
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        default: return "Key \(keyCode)"
        }
    }
}
