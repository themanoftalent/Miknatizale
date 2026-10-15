import SwiftUI

public struct AboutView: View {
    public var onClose: (() -> Void)?

    public init(onClose: (() -> Void)? = nil) {
        self.onClose = onClose
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // App Icon with comfortable top padding
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
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.blue.opacity(0.35), radius: 10, x: 0, y: 5)

                    // 3-pane window layout
                    HStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 25, height: 52)

                        VStack(spacing: 5) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .frame(width: 25, height: 23.5)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .frame(width: 25, height: 23.5)
                        }
                    }
                }
                .padding(.top, 24)

                VStack(spacing: 4) {
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
                    .padding(.horizontal, 20)

                // Feature Highlights
                HStack(spacing: 16) {
                    featurePill(title: "Hotkeys", icon: "command")
                    featurePill(title: "Edge Snapping", icon: "hand.draw")
                    featurePill(title: "Thirds & Quarters", icon: "rectangle.split.3x1")
                    featurePill(title: "Multi-Display", icon: "display.2")
                }
                .padding(.vertical, 2)

                Divider()

                // Open Source & Developer Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "curlybraces.square.fill")
                            .foregroundColor(.accentColor)
                        Text("Open Source | Free to Fork & Use")
                            .font(.headline)
                    }

                    Text("Feel free to fork, modify, use, and contribute!")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Developed by:")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Text("SoftAI Yazılım")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }

                        HStack(spacing: 6) {
                            Text("Developer:")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Text("Assoc. Prof. Dr. Mehmet Akif Cifci")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }

                        HStack(spacing: 6) {
                            Text("GitHub:")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Link("@themanoftalent", destination: URL(string: "https://github.com/themanoftalent")!)
                                .font(.caption.bold())
                        }
                    }
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)

                // Follow & Support Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                        Text("Follow & Support")
                            .font(.headline)
                    }

                    Text("If you find this project useful, star the repository, follow me, or buy me a coffee! Your support helps keep future projects free and open-source.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 10) {
                        supportButton(
                            title: "GitHub",
                            icon: "chevron.left.forwardslash.chevron.right",
                            url: "https://github.com/themanoftalent"
                        )

                        supportButton(
                            title: "Sponsor Me",
                            icon: "heart.fill",
                            url: "https://github.com/sponsors/themanoftalent",
                            color: .pink
                        )

                        supportButton(
                            title: "Buy Me a Coffee",
                            icon: "cup.and.saucer.fill",
                            url: "https://buymeacoffee.com/themanoftalent",
                            color: .orange
                        )
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)

                // Done Button (Closes window directly)
                Button("Done") {
                    handleDone()
                }
                .keyboardShortcut(.defaultAction)
                .keyboardShortcut(.cancelAction)
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .padding(.top, 6)
                .padding(.bottom, 20)
            }
            .padding(.vertical, 8)
        }
        .frame(width: 480, height: 640)
    }

    private func handleDone() {
        if let onClose = onClose {
            onClose()
        } else {
            // Find and close any open About window
            for window in NSApp.windows where window.title == "About Miknatizale" {
                window.close()
            }
        }
    }

    @ViewBuilder
    private func featurePill(title: String, icon: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.accentColor)
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func supportButton(title: String, icon: String, url: String, color: Color = .accentColor) -> some View {
        Button(action: {
            if let targetURL = URL(string: url) {
                NSWorkspace.shared.open(targetURL)
            }
        }) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption.bold())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
