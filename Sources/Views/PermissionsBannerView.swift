import SwiftUI

public struct PermissionsBannerView: View {
    @ObservedObject var accessibility = AccessibilityManager.shared

    public init() {}

    public var body: some View {
        if !accessibility.isGranted {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Accessibility Access Needed")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Miknatizale requires Accessibility permission to resize and reposition your windows.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    Button("Check Status") {
                        _ = accessibility.checkStatus(prompt: false)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)

                    Button("Grant Access") {
                        accessibility.requestPermission()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.orange.opacity(0.35), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }
}
