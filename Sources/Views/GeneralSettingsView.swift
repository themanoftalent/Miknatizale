import SwiftUI

public class GeneralSettingsViewModel: ObservableObject {
    @Published public var showingResetAlert = false
    @Published public var importSuccessBanner = false
    public init() {}
}

public struct GeneralSettingsView: View {
    @ObservedObject var settings = UserSettings.shared
    @ObservedObject var accessibility = AccessibilityManager.shared
    @StateObject private var viewModel = GeneralSettingsViewModel()

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(spacing: 12) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                    Text("General Preferences")
                        .font(.title2.bold())
                }

                Divider()

                // Shortcut Presets Card
                VStack(alignment: .leading, spacing: 14) {
                    Text("Shortcut Presets")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        Button(action: {
                            settings.applyRectanglePreset()
                            HotKeyManager.shared.registerAll()
                            MenuBarController.shared.rebuildMenu()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Rectangle Preset")
                                        .font(.headline)
                                    if settings.activePreset.contains("Rectangle") {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                Text("⌥⌘ Arrows for halves, ⌃⌘ for corners, ⌥⌘F for maximize")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(settings.activePreset.contains("Rectangle")
                                          ? Color.accentColor.opacity(0.12)
                                          : Color.primary.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(settings.activePreset.contains("Rectangle")
                                                    ? Color.accentColor
                                                    : Color.primary.opacity(0.1), lineWidth: 1.5)
                                    )
                            )
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            settings.applyMagnetPreset()
                            HotKeyManager.shared.registerAll()
                            MenuBarController.shared.rebuildMenu()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Magnet Preset")
                                        .font(.headline)
                                    if settings.activePreset == "Magnet" {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                Text("⌃⌥ Arrows for halves, ⌃⌥U/I/J/K for corners, ⌃⌥↩ for maximize")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(settings.activePreset == "Magnet"
                                          ? Color.accentColor.opacity(0.12)
                                          : Color.primary.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(settings.activePreset == "Magnet"
                                                    ? Color.accentColor
                                                    : Color.primary.opacity(0.1), lineWidth: 1.5)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    if RectangleImporter.shared.isRectangleInstalled {
                        Divider()

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Inherit from Installed Rectangle")
                                    .font(.body.weight(.medium))
                                Text("Import your customized keybindings directly from Rectangle's preferences.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Button(action: {
                                settings.applyRectanglePreset()
                                HotKeyManager.shared.registerAll()
                                MenuBarController.shared.rebuildMenu()
                                viewModel.importSuccessBanner = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                    viewModel.importSuccessBanner = false
                                }
                            }) {
                                Label("Import from Rectangle", systemImage: "arrow.down.doc.fill")
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        if viewModel.importSuccessBanner {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Successfully imported shortcuts from Rectangle!")
                                    .font(.caption.bold())
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 4)
                            .transition(.opacity)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08), lineWidth: 1))
                )

                // System & Permissions Card
                VStack(alignment: .leading, spacing: 14) {
                    Text("System Integration")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Accessibility Permission")
                                .font(.body.weight(.medium))
                            Text(accessibility.isGranted
                                 ? "Permission granted. Miknatizale can manage windows."
                                 : "Permission required to control and snap application windows.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if accessibility.isGranted {
                            Label("Granted", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.subheadline.bold())
                        } else {
                            Button("Grant Access") {
                                accessibility.requestPermission()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }

                    Divider()

                    Toggle(isOn: $settings.launchAtLogin) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Launch at Login")
                                .font(.body.weight(.medium))
                            Text("Start Miknatizale automatically when you log into your Mac.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .toggleStyle(.switch)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08), lineWidth: 1))
                )

                // Window Snapping Behavior Card
                VStack(alignment: .leading, spacing: 14) {
                    Text("Window Snapping Behavior")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Toggle(isOn: $settings.isDragSnappingEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Enable Window Dragging (Trigger Areas)")
                                .font(.body.weight(.medium))
                            Text("Drag windows to screen edges and corners to snap with visual preview.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .toggleStyle(.switch)

                    Divider()

                    Toggle(isOn: $settings.cycleRepeatedPresses) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cycle Repeated Presses")
                                .font(.body.weight(.medium))
                            Text("Repeatedly pressing Halves shortcuts cycles through 1/2, 1/3, and 2/3 widths.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .toggleStyle(.switch)

                    Divider()

                    Toggle(isOn: $settings.playFeedbackSound) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sound Feedback")
                                .font(.body.weight(.medium))
                            Text("Play a subtle sound when a window snaps into place.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .toggleStyle(.switch)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08), lineWidth: 1))
                )

                // Window Margin / Gap Card
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Window Margin / Gap")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Add clean spacing between tiled windows and screen edges.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Text(settings.windowGap == 0 ? "Seamless (0 px)" : "\(Int(settings.windowGap)) px")
                            .font(.subheadline.bold())
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.accentColor.opacity(0.12))
                            )
                    }

                    Slider(value: $settings.windowGap, in: 0...30, step: 2)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08), lineWidth: 1))
                )

                // Ignored Applications Card
                VStack(alignment: .leading, spacing: 14) {
                    Text("Ignored Applications")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Windows belonging to these applications will never be moved or snapped.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if settings.ignoredBundleIdentifiers.isEmpty {
                        Text("No applications currently ignored.")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.7))
                            .padding(.vertical, 4)
                    } else {
                        ForEach(Array(settings.ignoredBundleIdentifiers), id: \.self) { bundleId in
                            HStack {
                                Text(bundleId)
                                    .font(.system(.subheadline, design: .monospaced))
                                Spacer()
                                Button(action: {
                                    settings.toggleAppIgnored(bundleIdentifier: bundleId)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08), lineWidth: 1))
                )

                // Reset Defaults
                HStack {
                    Spacer()
                    Button("Reset All Shortcuts & Settings...") {
                        viewModel.showingResetAlert = true
                    }
                    .foregroundColor(.red)
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
            }
            .padding(24)
        }
        .alert(isPresented: $viewModel.showingResetAlert) {
            Alert(
                title: Text("Reset to Defaults?"),
                message: Text("All custom hotkeys and preferences will be restored to their original Miknatizale defaults."),
                primaryButton: .destructive(Text("Reset")) {
                    settings.resetToDefaults()
                    HotKeyManager.shared.registerAll()
                    MenuBarController.shared.rebuildMenu()
                },
                secondaryButton: .cancel()
            )
        }
    }
}
