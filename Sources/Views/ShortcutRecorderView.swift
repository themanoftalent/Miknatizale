import SwiftUI
import Carbon

public class ShortcutRecorderViewModel: ObservableObject {
    @Published public var isRecording: Bool = false
    private var monitor: Any?

    public init() {}

    public func startRecording(action: SnapAction, settings: UserSettings) {
        stopRecording()
        isRecording = true

        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self = self else { return event }

            // Cancel on Escape
            if event.keyCode == UInt16(kVK_Escape) {
                self.stopRecording()
                return nil
            }

            var carbonModifiers: UInt32 = 0
            if event.modifierFlags.contains(.control) {
                carbonModifiers |= UInt32(controlKey)
            }
            if event.modifierFlags.contains(.option) {
                carbonModifiers |= UInt32(optionKey)
            }
            if event.modifierFlags.contains(.shift) {
                carbonModifiers |= UInt32(shiftKey)
            }
            if event.modifierFlags.contains(.command) {
                carbonModifiers |= UInt32(cmdKey)
            }

            // Require at least one modifier key
            if carbonModifiers != 0 {
                let combo = KeyCombination(keyCode: UInt32(event.keyCode), carbonModifiers: carbonModifiers)
                settings.setKeyCombination(combo, for: action)
                HotKeyManager.shared.registerAll()
                MenuBarController.shared.rebuildMenu()
                self.stopRecording()
                return nil
            }

            return event
        }
    }

    public func stopRecording() {
        if let m = monitor {
            NSEvent.removeMonitor(m)
            monitor = nil
        }
        isRecording = false
    }

    deinit {
        stopRecording()
    }
}

public struct ShortcutRecorderView: View {
    public let action: SnapAction
    @ObservedObject var settings = UserSettings.shared
    @StateObject private var viewModel = ShortcutRecorderViewModel()

    public init(action: SnapAction) {
        self.action = action
    }

    public var body: some View {
        Button(action: {
            if viewModel.isRecording {
                viewModel.stopRecording()
            } else {
                viewModel.startRecording(action: action, settings: settings)
            }
        }) {
            HStack(spacing: 4) {
                if viewModel.isRecording {
                    Text("Type shortcut...")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                } else {
                    let combo = settings.keyCombination(for: action)
                    ForEach(combo.modifierSymbols, id: \.self) { sym in
                        keyCapBadge(text: sym)
                    }
                    keyCapBadge(text: combo.keyName)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(viewModel.isRecording ? Color.accentColor : Color.primary.opacity(0.15), lineWidth: viewModel.isRecording ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .onDisappear {
            viewModel.stopRecording()
        }
    }

    @ViewBuilder
    private func keyCapBadge(text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .monospaced))
            .foregroundColor(.primary)
            .frame(minWidth: 20, minHeight: 20)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 0.8)
            )
    }
}
