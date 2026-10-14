import SwiftUI

public struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            // App Icon
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.12, green: 0.65, blue: 1.0),
                                Color(red: 0.05, green: 0.40, blue: 0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .shadow(color: Color.blue.opacity(0.35), radius: 10, x: 0, y: 5)

                // 3-pane window layout
                HStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 28, height: 60)

                    VStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 28, height: 27.5)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 28, height: 27.5)
                    }
                }
            }

            VStack(spacing: 6) {
                Text("Miknatizale")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("Organize Your Workspace")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Version 3.0")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.8))
            }

            Text("Miknatizale declutters your screen by snapping windows into organized tiles. Activated by customizable trigger areas, keyboard shortcuts, or via the menu bar.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)

            Divider()

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Image(systemName: "command")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                    Text("Hotkeys")
                        .font(.caption.bold())
                }

                VStack(spacing: 4) {
                    Image(systemName: "hand.draw")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                    Text("Edge Snapping")
                        .font(.caption.bold())
                }

                VStack(spacing: 4) {
                    Image(systemName: "rectangle.split.3x1")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                    Text("Thirds & Quarters")
                        .font(.caption.bold())
                }

                VStack(spacing: 4) {
                    Image(systemName: "display.2")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                    Text("Multi-Display")
                        .font(.caption.bold())
                }
            }
            .padding(.vertical, 4)

            Button("Done") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
        }
        .padding(30)
        .frame(width: 440)
    }
}
