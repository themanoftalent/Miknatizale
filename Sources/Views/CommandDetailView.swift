import SwiftUI

public struct CommandDetailView: View {
    public let action: SnapAction
    @ObservedObject var settings = UserSettings.shared

    public init(action: SnapAction) {
        self.action = action
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header
                HStack(spacing: 14) {
                    Image(systemName: action.systemIcon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.accentColor)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.accentColor.opacity(0.12))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(action.title)
                            .font(.title2.bold())
                        Text(action.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Test Action Button
                    Button(action: {
                        WindowManager.shared.snapActiveWindow(to: action)
                    }) {
                        Label("Test Snap", systemImage: "play.fill")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.bottom, 4)

                Divider()

                // Section 1: Intended window size and position
                LayoutGridVisualizer(action: action)

                // Section 2: Keyboard Shortcut
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Keyboard shortcut")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Press to record a custom hotkey combination")
                                .font(.caption)
                                .foregroundColor(.secondary.opacity(0.8))
                        }

                        Spacer()

                        ShortcutRecorderView(action: action)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(nsColor: .controlBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                    )
                }

                // Section 3: Activation area for dragging
                if action.supportsDragActivation {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Activation area for dragging")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text(action.triggerAreaDescription)
                                    .font(.caption)
                                    .foregroundColor(.secondary.opacity(0.8))
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { settings.isDragTriggerEnabled(for: action) },
                                set: { settings.setDragTriggerEnabled($0, for: action) }
                            ))
                            .toggleStyle(.switch)
                        }

                        DragTriggerVisualizer(
                            action: action,
                            isEnabled: settings.isDragTriggerEnabled(for: action)
                        )
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(nsColor: .controlBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                    )
                }

                if let next = action.nextInCycle {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.accentColor)
                        Text("Repeated presses cycle to **\(next.title)**")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(24)
        }
    }
}
