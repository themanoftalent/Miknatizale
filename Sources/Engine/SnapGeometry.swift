import Foundation
import CoreGraphics

public struct SnapGeometry {
    /// Calculates the target window rect in Quartz coordinates based on the snap action, visible frame, and window gap.
    public static func targetRect(for action: SnapAction, in visibleFrame: CGRect, currentWindowRect: CGRect? = nil, gap: CGFloat = 0.0) -> CGRect {
        let g = max(0, gap)
        let v = visibleFrame
        let cur = currentWindowRect ?? CGRect(x: v.midX - 300, y: v.midY - 250, width: 600, height: 500)

        switch action {
        // Halves
        case .left:
            let w = g > 0 ? (v.width - 3 * g) / 2.0 : v.width / 2.0
            let h = g > 0 ? v.height - 2 * g : v.height
            let x = v.minX + (g > 0 ? g : 0)
            let y = v.minY + (g > 0 ? g : 0)
            return CGRect(x: x, y: y, width: w, height: h)

        case .right:
            let w = g > 0 ? (v.width - 3 * g) / 2.0 : v.width / 2.0
            let h = g > 0 ? v.height - 2 * g : v.height
            let x = g > 0 ? v.minX + 2 * g + w : v.minX + v.width / 2.0
            let y = v.minY + (g > 0 ? g : 0)
            return CGRect(x: x, y: y, width: w, height: h)

        case .top:
            let w = g > 0 ? v.width - 2 * g : v.width
            let h = g > 0 ? (v.height - 3 * g) / 2.0 : v.height / 2.0
            let x = v.minX + (g > 0 ? g : 0)
            let y = v.minY + (g > 0 ? g : 0)
            return CGRect(x: x, y: y, width: w, height: h)

        case .bottom:
            let w = g > 0 ? v.width - 2 * g : v.width
            let h = g > 0 ? (v.height - 3 * g) / 2.0 : v.height / 2.0
            let x = v.minX + (g > 0 ? g : 0)
            let y = g > 0 ? v.minY + 2 * g + h : v.minY + v.height / 2.0
            return CGRect(x: x, y: y, width: w, height: h)

        // Corners
        case .topLeft:
            let w = g > 0 ? (v.width - 3 * g) / 2.0 : v.width / 2.0
            let h = g > 0 ? (v.height - 3 * g) / 2.0 : v.height / 2.0
            let x = v.minX + (g > 0 ? g : 0)
            let y = v.minY + (g > 0 ? g : 0)
            return CGRect(x: x, y: y, width: w, height: h)

        case .topRight:
            let w = g > 0 ? (v.width - 3 * g) / 2.0 : v.width / 2.0
            let h = g > 0 ? (v.height - 3 * g) / 2.0 : v.height / 2.0
            let x = g > 0 ? v.minX + 2 * g + w : v.minX + v.width / 2.0
            let y = v.minY + (g > 0 ? g : 0)
            return CGRect(x: x, y: y, width: w, height: h)

        case .bottomLeft:
            let w = g > 0 ? (v.width - 3 * g) / 2.0 : v.width / 2.0
            let h = g > 0 ? (v.height - 3 * g) / 2.0 : v.height / 2.0
            let x = v.minX + (g > 0 ? g : 0)
            let y = g > 0 ? v.minY + 2 * g + h : v.minY + v.height / 2.0
            return CGRect(x: x, y: y, width: w, height: h)

        case .bottomRight:
            let w = g > 0 ? (v.width - 3 * g) / 2.0 : v.width / 2.0
            let h = g > 0 ? (v.height - 3 * g) / 2.0 : v.height / 2.0
            let x = g > 0 ? v.minX + 2 * g + w : v.minX + v.width / 2.0
            let y = g > 0 ? v.minY + 2 * g + h : v.minY + v.height / 2.0
            return CGRect(x: x, y: y, width: w, height: h)

        // Thirds
        case .leftThird:
            let w = g > 0 ? (v.width - 4 * g) / 3.0 : v.width / 3.0
            let h = g > 0 ? v.height - 2 * g : v.height
            let x = v.minX + (g > 0 ? g : 0)
            let y = v.minY + (g > 0 ? g : 0)
            return CGRect(x: x, y: y, width: w, height: h)

        case .centerThird:
            let w = g > 0 ? (v.width - 4 * g) / 3.0 : v.width / 3.0
            let h = g > 0 ? v.height - 2 * g : v.height
            let x = g > 0 ? v.minX + 2 * g + w : v.minX + v.width / 3.0
            let y = v.minY + (g > 0 ? g : 0)
            return CGRect(x: x, y: y, width: w, height: h)

        case .rightThird:
            let w = g > 0 ? (v.width - 4 * g) / 3.0 : v.width / 3.0
            let h = g > 0 ? v.height - 2 * g : v.height
            let x = g > 0 ? v.minX + 3 * g + 2 * w : v.minX + 2 * (v.width / 3.0)
            let y = v.minY + (g > 0 ? g : 0)
            return CGRect(x: x, y: y, width: w, height: h)

        // Two Thirds
        case .leftTwoThirds:
            let unitW = g > 0 ? (v.width - 4 * g) / 3.0 : v.width / 3.0
            let w = g > 0 ? 2 * unitW + g : 2 * (v.width / 3.0)
            let h = g > 0 ? v.height - 2 * g : v.height
            let x = v.minX + (g > 0 ? g : 0)
            let y = v.minY + (g > 0 ? g : 0)
            return CGRect(x: x, y: y, width: w, height: h)

        case .centerTwoThirds:
            let unitW = g > 0 ? (v.width - 4 * g) / 3.0 : v.width / 3.0
            let w = g > 0 ? 2 * unitW + g : 2 * (v.width / 3.0)
            let h = g > 0 ? v.height - 2 * g : v.height
            let x = v.minX + (v.width - w) / 2.0
            let y = v.minY + (g > 0 ? g : 0)
            return CGRect(x: x, y: y, width: w, height: h)

        case .rightTwoThirds:
            let unitW = g > 0 ? (v.width - 4 * g) / 3.0 : v.width / 3.0
            let w = g > 0 ? 2 * unitW + g : 2 * (v.width / 3.0)
            let h = g > 0 ? v.height - 2 * g : v.height
            let x = v.maxX - w - (g > 0 ? g : 0)
            let y = v.minY + (g > 0 ? g : 0)
            return CGRect(x: x, y: y, width: w, height: h)

        // Maximize & Sizing
        case .maximize:
            let w = g > 0 ? v.width - 2 * g : v.width
            let h = g > 0 ? v.height - 2 * g : v.height
            let x = v.minX + (g > 0 ? g : 0)
            let y = v.minY + (g > 0 ? g : 0)
            return CGRect(x: x, y: y, width: w, height: h)

        case .almostMaximize:
            let insetX = max(v.width * 0.04, 30.0)
            let insetY = max(v.height * 0.04, 25.0)
            return CGRect(x: v.minX + insetX, y: v.minY + insetY, width: v.width - 2 * insetX, height: v.height - 2 * insetY)

        case .maximizeHeight:
            let x = max(v.minX + g, min(cur.minX, v.maxX - cur.width - g))
            let w = min(cur.width, v.width - 2 * g)
            let y = v.minY + (g > 0 ? g : 0)
            let h = g > 0 ? v.height - 2 * g : v.height
            return CGRect(x: x, y: y, width: w, height: h)

        case .larger:
            let deltaW = v.width * 0.08
            let deltaH = v.height * 0.08
            let newW = min(v.width - 2 * g, cur.width + deltaW)
            let newH = min(v.height - 2 * g, cur.height + deltaH)
            let newX = max(v.minX + g, min(cur.midX - (newW / 2.0), v.maxX - newW - g))
            let newY = max(v.minY + g, min(cur.midY - (newH / 2.0), v.maxY - newH - g))
            return CGRect(x: newX, y: newY, width: newW, height: newH)

        case .smaller:
            let deltaW = v.width * 0.08
            let deltaH = v.height * 0.08
            let newW = max(300.0, cur.width - deltaW)
            let newH = max(200.0, cur.height - deltaH)
            let newX = max(v.minX + g, min(cur.midX - (newW / 2.0), v.maxX - newW - g))
            let newY = max(v.minY + g, min(cur.midY - (newH / 2.0), v.maxY - newH - g))
            return CGRect(x: newX, y: newY, width: newW, height: newH)

        case .center:
            let w = min(cur.width, v.width - 2 * g)
            let h = min(cur.height, v.height - 2 * g)
            let x = v.minX + (v.width - w) / 2.0
            let y = v.minY + (v.height - h) / 2.0
            return CGRect(x: x, y: y, width: w, height: h)

        // Move to Edge (preserve size)
        case .moveLeft:
            return CGRect(x: v.minX + g, y: cur.minY, width: cur.width, height: cur.height)
        case .moveRight:
            return CGRect(x: v.maxX - cur.width - g, y: cur.minY, width: cur.width, height: cur.height)
        case .moveUp:
            return CGRect(x: cur.minX, y: v.minY + g, width: cur.width, height: cur.height)
        case .moveDown:
            return CGRect(x: cur.minX, y: v.maxY - cur.height - g, width: cur.width, height: cur.height)

        // Fourths
        case .firstFourth:
            let w = (v.width - (g * 5)) / 4.0
            return CGRect(x: v.minX + g, y: v.minY + g, width: w, height: v.height - 2 * g)
        case .secondFourth:
            let w = (v.width - (g * 5)) / 4.0
            return CGRect(x: v.minX + 2 * g + w, y: v.minY + g, width: w, height: v.height - 2 * g)
        case .thirdFourth:
            let w = (v.width - (g * 5)) / 4.0
            return CGRect(x: v.minX + 3 * g + 2 * w, y: v.minY + g, width: w, height: v.height - 2 * g)
        case .fourthFourth:
            let w = (v.width - (g * 5)) / 4.0
            return CGRect(x: v.minX + 4 * g + 3 * w, y: v.minY + g, width: w, height: v.height - 2 * g)

        // Sixths
        case .topLeftSixth:
            let w = (v.width - (g * 4)) / 3.0
            let h = (v.height - (g * 3)) / 2.0
            return CGRect(x: v.minX + g, y: v.minY + g, width: w, height: h)
        case .topCenterSixth:
            let w = (v.width - (g * 4)) / 3.0
            let h = (v.height - (g * 3)) / 2.0
            return CGRect(x: v.minX + 2 * g + w, y: v.minY + g, width: w, height: h)
        case .topRightSixth:
            let w = (v.width - (g * 4)) / 3.0
            let h = (v.height - (g * 3)) / 2.0
            return CGRect(x: v.minX + 3 * g + 2 * w, y: v.minY + g, width: w, height: h)
        case .bottomLeftSixth:
            let w = (v.width - (g * 4)) / 3.0
            let h = (v.height - (g * 3)) / 2.0
            return CGRect(x: v.minX + g, y: v.minY + 2 * g + h, width: w, height: h)
        case .bottomCenterSixth:
            let w = (v.width - (g * 4)) / 3.0
            let h = (v.height - (g * 3)) / 2.0
            return CGRect(x: v.minX + 2 * g + w, y: v.minY + 2 * g + h, width: w, height: h)
        case .bottomRightSixth:
            let w = (v.width - (g * 4)) / 3.0
            let h = (v.height - (g * 3)) / 2.0
            return CGRect(x: v.minX + 3 * g + 2 * w, y: v.minY + 2 * g + h, width: w, height: h)

        case .restore, .nextDisplay, .previousDisplay:
            return v
        }
    }
}
