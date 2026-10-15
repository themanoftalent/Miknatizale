import SwiftUI

/// Compact, high-contrast keycap row used in the Preferences sidebar.
/// Each modifier and the key get their own small keycap so shortcuts are easy to read
/// in both light/dark mode and on the selected (accent-colored) row.
public struct SidebarShortcutBadge: View {
    public let combo: KeyCombination

    public init(combo: KeyCombination) {
        self.combo = combo
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(Array((combo.modifierSymbols + [combo.keyName]).enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(minWidth: 17, minHeight: 17)
                    .padding(.horizontal, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.primary.opacity(0.10))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(Color.primary.opacity(0.18), lineWidth: 0.5)
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Shortcut \(combo.displayString)")
    }
}
