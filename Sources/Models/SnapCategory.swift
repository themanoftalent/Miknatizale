import Foundation

public enum SnapCategory: String, CaseIterable, Identifiable, Codable {
    case horizontal = "Horizontal"
    case corners = "Corners"
    case thirds = "Thirds & Two Thirds"
    case fourths = "Fourths"
    case sixths = "Sixths"
    case sizeAndPosition = "Size & Position"
    case moveToEdge = "Move to Edge"
    case displays = "Displays"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .horizontal: return "rectangle.split.2x1"
        case .corners: return "rectangle.split.2x2"
        case .thirds: return "rectangle.split.3x1"
        case .fourths: return "square.grid.2x2"
        case .sixths: return "square.grid.3x2"
        case .sizeAndPosition: return "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        case .moveToEdge: return "arrow.up.and.down.and.arrow.left.and.right"
        case .displays: return "display.2"
        }
    }
}
