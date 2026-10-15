import Cocoa

public class MenuIcons {
    /// Generates Magnet's signature 3-pane logo for the menu bar status item
    public static func magnetStatusBarIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let img = NSImage(size: size, flipped: false) { rect in
            let insetRect = rect.insetBy(dx: 1.5, dy: 1.5)
            let path = NSBezierPath(roundedRect: insetRect, xRadius: 3.5, yRadius: 3.5)
            path.lineWidth = 1.3
            NSColor.labelColor.setStroke()
            path.stroke()

            // Divider vertical
            let divX = insetRect.minX + (insetRect.width * 0.48)
            let vLine = NSBezierPath()
            vLine.move(to: NSPoint(x: divX, y: insetRect.minY + 1))
            vLine.line(to: NSPoint(x: divX, y: insetRect.maxY - 1))
            vLine.lineWidth = 1.2
            vLine.stroke()

            // Divider horizontal on right side
            let divY = insetRect.minY + (insetRect.height * 0.5)
            let hLine = NSBezierPath()
            hLine.move(to: NSPoint(x: divX, y: divY))
            hLine.line(to: NSPoint(x: insetRect.maxX - 1, y: divY))
            hLine.lineWidth = 1.2
            hLine.stroke()

            return true
        }
        img.isTemplate = true
        return img
    }

    /// Generates miniature layout icon for a snap action in the dropdown menu
    public static func icon(for action: SnapAction) -> NSImage {
        let size = NSSize(width: 16, height: 16)
        let img = NSImage(size: size, flipped: false) { rect in
            let frame = rect.insetBy(dx: 1.5, dy: 1.5)
            let outline = NSBezierPath(roundedRect: frame, xRadius: 2.5, yRadius: 2.5)
            outline.lineWidth = 1.0
            NSColor.labelColor.withAlphaComponent(0.4).setStroke()
            outline.stroke()

            // Normalized rect: in Cocoa coordinates Y=0 is bottom, so we invert Y for drawing
            let norm = action.normalizedRect
            let innerX = frame.minX + (frame.width * norm.origin.x)
            let innerH = frame.height * norm.height
            let innerY = frame.maxY - (frame.height * norm.origin.y) - innerH
            let innerW = frame.width * norm.width

            let innerRect = NSRect(x: innerX, y: innerY, width: innerW, height: innerH).insetBy(dx: 0.5, dy: 0.5)
            let fillPath = NSBezierPath(roundedRect: innerRect, xRadius: 1.5, yRadius: 1.5)
            NSColor.labelColor.setFill()
            fillPath.fill()

            return true
        }
        img.isTemplate = true
        return img
    }
}
