import SwiftUI

public struct LayoutGridVisualizer: View {
    public let action: SnapAction

    private let cols = 18
    private let rows = 12

    public init(action: SnapAction) {
        self.action = action
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Intended window size and position")
                .font(.headline)
                .foregroundColor(.secondary)

            ZStack {
                // Monitor Bezel
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)

                // Screen Display Grid
                VStack(spacing: 3) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 3) {
                            ForEach(0..<cols, id: \.self) { col in
                                let isActive = isCellActive(col: col, row: row)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(isActive ? Color.accentColor : Color.primary.opacity(0.06))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isActive)
                            }
                        }
                    }
                }
                .padding(14)
            }
            .frame(height: 180)
        }
    }

    private func isCellActive(col: Int, row: Int) -> Bool {
        let norm = action.normalizedRect

        let cellNormX = Double(col) / Double(cols)
        let cellNormY = Double(row) / Double(rows)
        let cellWidth = 1.0 / Double(cols)
        let cellHeight = 1.0 / Double(rows)

        let cellRect = CGRect(x: cellNormX, y: cellNormY, width: cellWidth, height: cellHeight)
        let actionRect = CGRect(x: norm.minX, y: norm.minY, width: norm.width, height: norm.height)

        return cellRect.intersects(actionRect) &&
               cellRect.midX >= norm.minX && cellRect.midX <= norm.maxX &&
               cellRect.midY >= norm.minY && cellRect.midY <= norm.maxY
    }
}
