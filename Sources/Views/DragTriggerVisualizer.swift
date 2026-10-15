import SwiftUI

public struct DragTriggerVisualizer: View {
    public let action: SnapAction
    public let isEnabled: Bool

    public init(action: SnapAction, isEnabled: Bool) {
        self.action = action
        self.isEnabled = isEnabled
    }

    public var body: some View {
        ZStack {
            // Monitor Bezel
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1.5)
                )

            // Grid background
            VStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { _ in
                    HStack(spacing: 8) {
                        ForEach(0..<14, id: \.self) { _ in
                            Circle()
                                .fill(Color.primary.opacity(0.08))
                                .frame(width: 3, height: 3)
                        }
                    }
                }
            }

            // Trigger Zone Indicator
            if isEnabled && action.supportsDragActivation {
                triggerIndicator
                    .transition(.opacity)
            } else if !action.supportsDragActivation {
                Text("Not applicable for this command")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Activation area disabled")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 110)
    }

    @ViewBuilder
    private var triggerIndicator: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            switch action {
            case .left:
                // Left edge strip
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accentColor)
                    .frame(width: 6, height: h * 0.6)
                    .position(x: 7, y: h / 2)
                    .shadow(color: Color.accentColor.opacity(0.6), radius: 6)

            case .right:
                // Right edge strip
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accentColor)
                    .frame(width: 6, height: h * 0.6)
                    .position(x: w - 7, y: h / 2)
                    .shadow(color: Color.accentColor.opacity(0.6), radius: 6)

            case .top, .maximize:
                // Top edge strip
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accentColor)
                    .frame(width: w * 0.6, height: 6)
                    .position(x: w / 2, y: 7)
                    .shadow(color: Color.accentColor.opacity(0.6), radius: 6)

            case .bottom:
                // Bottom edge strip
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accentColor)
                    .frame(width: w * 0.6, height: 6)
                    .position(x: w / 2, y: h - 7)
                    .shadow(color: Color.accentColor.opacity(0.6), radius: 6)

            case .topLeft:
                // Top-left corner
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 14, height: 14)
                    .position(x: 12, y: 12)
                    .shadow(color: Color.accentColor.opacity(0.6), radius: 6)

            case .topRight:
                // Top-right corner
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 14, height: 14)
                    .position(x: w - 12, y: 12)
                    .shadow(color: Color.accentColor.opacity(0.6), radius: 6)

            case .bottomLeft:
                // Bottom-left corner
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 14, height: 14)
                    .position(x: 12, y: h - 12)
                    .shadow(color: Color.accentColor.opacity(0.6), radius: 6)

            case .bottomRight:
                // Bottom-right corner
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 14, height: 14)
                    .position(x: w - 12, y: h - 12)
                    .shadow(color: Color.accentColor.opacity(0.6), radius: 6)

            default:
                EmptyView()
            }
        }
    }
}
