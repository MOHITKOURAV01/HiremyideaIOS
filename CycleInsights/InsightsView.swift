import SwiftUI
import Charts

struct InsightsView: View {
    var body: some View {
        Text("Insights View")
    }
}

private struct StabilityDatum: Identifiable {
    let id = UUID()
    let month: String
    let lower: Double
    let center: Double
    let upper: Double
}

private struct CycleTrendDatum: Identifiable {
    let id = UUID()
    let month: String
    let value: Int
}

private struct WeightDatum: Identifiable {
    let id = UUID()
    let month: String
    let value: Int
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64

        switch cleaned.count {
        case 6:
            (a, r, g, b) = (255, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
        case 8:
            (a, r, g, b) = ((value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let appBackground = Color(hex: "F2F2F7")
    static let cardWhite = Color.white
    static let lavenderPrimary = Color(hex: "B8B0D8")
    static let lavenderLight = Color(hex: "D4CEEC")
    static let softPink = Color(hex: "F2A0A8")
    static let mintGreen = Color(hex: "A8C8B8")
    static let darkTeal = Color(hex: "5E8B7E")
    static let darkText = Color(hex: "1C1C1E")
    static let subText = Color(hex: "8E8E93")
    static let accentPurple = Color(hex: "8B7DB8")
}

#Preview {
    InsightsView()
}
