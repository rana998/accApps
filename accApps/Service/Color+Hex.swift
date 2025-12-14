import SwiftUI

extension Color {
    init?(hex: String) {
        let r, g, b, a: CGFloat
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }

        var int = UInt64()
        guard Scanner(string: hexSanitized).scanHexInt64(&int) else { return nil }

        switch hexSanitized.count {
        case 6:
            r = CGFloat((int & 0xFF0000) >> 16) / 255.0
            g = CGFloat((int & 0x00FF00) >> 8) / 255.0
            b = CGFloat(int & 0x0000FF) / 255.0
            a = 1.0
        case 8:
            r = CGFloat((int & 0xFF000000) >> 24) / 255.0
            g = CGFloat((int & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((int & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(int & 0x000000FF) / 255.0
        default:
            return nil
        }

        self = Color(red: r, green: g, blue: b, opacity: a)
    }

    func toHex(includeAlpha: Bool = false) -> String? {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }

        if includeAlpha {
            let rgba = (Int(r * 255) << 24) | (Int(g * 255) << 16) | (Int(b * 255) << 8) | Int(a * 255)
            return String(format: "#%08X", rgba)
        } else {
            let rgb = (Int(r * 255) << 16) | (Int(g * 255) << 8) | Int(b * 255)
            return String(format: "#%06X", rgb)
        }
    }
}
