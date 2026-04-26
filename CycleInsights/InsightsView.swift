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


private struct TopNavigationBar: View {
    let topInset: CGFloat
    let title: String

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "FCE8E8").opacity(0.7), Color(hex: "F2F2F7")],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 50)
            .ignoresSafeArea(edges: .top)

            HStack {
                DotGridLogo()
                Spacer()
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.darkText)
                Spacer()
                Color.clear
                    .frame(width: 20, height: 20)
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .frame(height: 50)
    }
}

private struct DotGridLogo: View {
    private let colors: [Color] = [.lavenderPrimary, .softPink, .mintGreen, .accentPurple]

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                ForEach(0..<2, id: \.self) { index in
                    Circle()
                        .fill(colors[index])
                        .frame(width: 8, height: 8)
                }
            }
            HStack(spacing: 2) {
                ForEach(2..<4, id: \.self) { index in
                    Circle()
                        .fill(colors[index])
                        .frame(width: 8, height: 8)
                }
            }
        }
        .frame(width: 20, height: 20)
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .bold, design: .default))
            .foregroundColor(.darkText)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardWhite)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
    }
}

private struct StabilitySummaryCard: View {
    let data: [StabilityDatum]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Based on your recent logs and symptom patterns.")
                .font(.system(size: 13))
                .foregroundColor(.subText)

            VStack(alignment: .leading, spacing: 2) {
                Text("Stability Score")
                    .font(.system(size: 14))
                    .foregroundColor(.subText)

                Text("78%")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(.darkText)
            }
            
            Chart {
                ForEach(data) { item in
                    AreaMark(
                        x: .value("Month", item.month),
                        yStart: .value("Lower", item.lower),
                        yEnd: .value("Upper", item.upper)
                    )
                    .foregroundStyle(Color.lavenderPrimary.opacity(0.32))
                    .interpolationMethod(.catmullRom)
                }

                ForEach(data) { item in
                    LineMark(
                        x: .value("Month", item.month),
                        y: .value("Center", item.center)
                    )
                    .foregroundStyle(Color.lavenderPrimary)
                    .lineStyle(.init(lineWidth: 2))
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 130)
            .padding(.top, 8)
            .clipped()
            .chartYScale(domain: 24...32)
            .chartXAxis {
                AxisMarks(values: data.map(\.month)) { value in
                    AxisValueLabel {
                        if let month = value.as(String.self) {
                            Text(month)
                                .font(.system(size: 12))
                                .foregroundColor(.subText)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [24, 28, 32]) { value in
                    AxisValueLabel {
                        if let day = value.as(Int.self) {
                            Text("\(day)d")
                                .font(.system(size: 12))
                                .foregroundColor(.subText)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
}

#Preview {



    InsightsView()
}
