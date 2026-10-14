import Cocoa

public class SnapPreviewOverlay {
    public static let shared = SnapPreviewOverlay()

    private var panel: NSPanel?
    private var previewBox: NSBox?
    private var isVisible: Bool = false

    private init() {
        setupPanel()
    }

    private func setupPanel() {
        let p = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.isOpaque = false
        p.backgroundColor = .clear
        p.level = .floating
        p.ignoresMouseEvents = true
        p.hasShadow = true
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let box = NSBox(frame: .zero)
        box.boxType = .custom
        box.cornerRadius = 14
        box.borderWidth = 2.5
        box.borderColor = NSColor.systemBlue.withAlphaComponent(0.85)
        box.fillColor = NSColor.systemBlue.withAlphaComponent(0.22)

        p.contentView = box
        self.previewBox = box
        self.panel = p
    }

    public func show(targetQuartzRect: CGRect, on screen: NSScreen) {
        guard let panel = panel else { return }

        // Convert Quartz rect to Cocoa rect
        let cocoaRect = ScreenManager.shared.quartzToCocoa(rect: targetQuartzRect)

        if !isVisible {
            panel.setFrame(cocoaRect, display: true)
            panel.alphaValue = 0
            panel.orderFrontRegardless()
            isVisible = true

            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                panel.animator().alphaValue = 1.0
            }
        } else {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.12
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                panel.animator().setFrame(cocoaRect, display: true)
                panel.animator().alphaValue = 1.0
            }
        }
    }

    public func hide() {
        guard let panel = panel, isVisible else { return }
        isVisible = false

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.12
            panel.animator().alphaValue = 0.0
        }, completionHandler: {
            if !self.isVisible {
                panel.orderOut(nil)
            }
        })
    }
}
