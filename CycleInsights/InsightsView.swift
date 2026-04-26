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
            .chartOverlay { proxy in
                GeometryReader { geo in
                    let month = data[data.count - 1].month
                    let center = data[data.count - 1].center
                    
                    if let x = proxy.position(forX: month),
                       let y = proxy.position(forY: center) {
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Stability Improving")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.mintGreen)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            
                            Triangle()
                                .fill(Color.mintGreen)
                                .frame(width: 8, height: 4)
                        }
                        .position(x: x, y: y - 22)
                    }
                }
            }
        }
        .cardStyle()
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct CycleTrendsSection: View {
    let data: [CycleTrendDatum]
    @Binding var cycleScrollOffset: Int
    @Binding var visibleStartIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                withAnimation {
                    visibleStartIndex = max(0, visibleStartIndex - 1)
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
                    .frame(width: 32, height: 32)
                    .overlay(Circle().stroke(Color.gray.opacity(0.3)))
            }
            .disabled(visibleStartIndex == 0)
            .opacity(visibleStartIndex == 0 ? 0.3 : 1.0)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(data) { item in
                            CycleTrendBar(datum: item)
                                .id(item.id)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(maxWidth: .infinity)
                .onChange(of: visibleStartIndex) { _, newValue in
                    withAnimation {
                        proxy.scrollTo(data[newValue].id, anchor: .leading)
                    }
                }
            }

            Button(action: {
                withAnimation {
                    visibleStartIndex = min(data.count - 1, visibleStartIndex + 1)
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .frame(width: 32, height: 32)
                    .overlay(Circle().stroke(Color.gray.opacity(0.3)))
            }
            .disabled(visibleStartIndex >= data.count - 1)
            .opacity(visibleStartIndex >= data.count - 1 ? 0.3 : 1.0)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
}

private struct CycleTrendBar: View {
    let datum: CycleTrendDatum
    @GestureState private var isPressed = false

    var body: some View {
        VStack(spacing: 6) {
            Text("\(datum.value)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.darkText)

            ZStack(alignment: .bottom) {
                // Lavender pill (full bar, rounded top only)
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(hex: "C4BEDE").opacity(0.6))
                    .frame(width: 50, height: 170)

                // Pink bottom section
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 22,
                    bottomTrailingRadius: 22,
                    topTrailingRadius: 0
                )
                .fill(Color(hex: "F2A0A8"))
                .frame(width: 50, height: 60)

                // Gear circle at junction point
                Circle()
                    .fill(Color(hex: "5E8B7E"))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    )
                    .offset(y: -40)
            }
            .frame(width: 50, height: 170)

            Text(datum.month)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "8E8E93"))
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in
                    state = true
                }
        )
    }
}

private struct WeightChartCard: View {
    let data: [WeightDatum]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current Weight")
                        .font(.system(size: 14))
                        .foregroundColor(.subText)
                    Text("64.5 kg")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.darkText)
                }
                Spacer()
                Text("+1.2 kg")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.softPink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.softPink.opacity(0.1))
                    .cornerRadius(6)
            }

            Chart {
                ForEach(data) { item in
                    AreaMark(
                        x: .value("Month", item.month),
                        y: .value("Weight", item.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.softPink.opacity(0.3), Color.softPink.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                ForEach(data) { item in
                    LineMark(
                        x: .value("Month", item.month),
                        y: .value("Weight", item.value)
                    )
                    .foregroundStyle(Color.softPink)
                    .lineStyle(.init(lineWidth: 3))
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 120)
            .chartYScale(domain: 60...70)
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
            .chartYAxis(.hidden)
        }
        .cardStyle()
    }
}

private struct SymptomDonutCard: View {
    let segments: [DonutSegment]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Symptom Distribution")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.darkText)
                Text("Most frequent symptoms this cycle.")
                    .font(.system(size: 13))
                    .foregroundColor(.subText)
            }

            HStack {
                Spacer()
                GeometryReader { geometry in
                    let size = min(geometry.size.width, 260)
                    let center = CGPoint(x: size / 2, y: size / 2)
                    let outerRadius = size * 0.38
                    let innerRadius = outerRadius * 0.6
                    let labelRadius = outerRadius + 72

                    ZStack {
                        Canvas { context, canvasSize in
                            let drawingCenter = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                            var startAngle = Angle.degrees(-90)

                            for segment in segments {
                                let gap = Angle.degrees(2.5)
                                let segmentAngle = Angle.degrees((segment.value / 100) * 360)
                                let endAngle = startAngle + segmentAngle - gap

                                var path = Path()
                                path.addArc(
                                    center: drawingCenter,
                                    radius: outerRadius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: false
                                )
                                path.addArc(
                                    center: drawingCenter,
                                    radius: innerRadius,
                                    startAngle: endAngle,
                                    endAngle: startAngle,
                                    clockwise: true
                                )
                                path.closeSubpath()

                                context.fill(path, with: .color(segment.color))
                                startAngle = startAngle + segmentAngle
                            }
                        }
                        .frame(width: size, height: size)
                        .overlay {
                            Circle()
                                .fill(Color.white)
                                .frame(width: innerRadius * 2, height: innerRadius * 2)
                        }

                        ForEach(positionedSegments(in: size, center: center, labelRadius: labelRadius)) { item in
                            DonutLabel(segment: item.segment)
                                .position(item.position)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 280)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .cardStyle()
    }

    private func positionedSegments(in size: CGFloat, center: CGPoint, labelRadius: CGFloat) -> [PositionedSegment] {
        var positioned: [PositionedSegment] = []
        var currentAngle = -90.0
        
        for segment in segments {
            let segmentAngle = (segment.value / 100.0) * 360.0
            let middleAngle = currentAngle + (segmentAngle / 2.0)
            let angleInRadians = middleAngle * .pi / 180.0
            
            let x = center.x + labelRadius * cos(angleInRadians)
            let y = center.y + labelRadius * sin(angleInRadians)
            
            positioned.append(PositionedSegment(segment: segment, position: CGPoint(x: x, y: y)))
            currentAngle += segmentAngle
        }
        return positioned
    }
}

private struct DonutLabel: View {
    let segment: DonutSegment
    
    var body: some View {
        VStack(spacing: 2) {
            Text(segment.name)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.darkText)
            Text("\(Int(segment.value))%")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.subText)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

private struct DonutSegment: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
}

private struct PositionedSegment: Identifiable {
    let id = UUID()
    let segment: DonutSegment
    let position: CGPoint
}

private struct LifestyleImpactCard: View {
    @State private var tappedCell: String? = nil
    
    private let rows = [
        LifestyleRow(label: "Sleep", filledCount: 8, color: .lavenderPrimary),
        LifestyleRow(label: "Stress", filledCount: 4, color: .softPink),
        LifestyleRow(label: "Activity", filledCount: 7, color: .mintGreen),
        LifestyleRow(label: "Diet", filledCount: 5, color: .darkTeal)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            controlsHeader

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Lifestyle Correlation Heatmap Placeholder")
                }
            }
        }
        .cardStyle()
    }

    private var controlsHeader: some View {
        HStack {
            Text("Correlation Strength")
                .font(.headline)
                .foregroundColor(.darkText)

            Spacer()

            HStack(spacing: 4) {
                Text("4 months")
                    .font(.subheadline)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .foregroundColor(.darkText)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.4))
            )
        }
        .padding(.bottom, 12)
    }
}

private struct LifestyleRow: Identifiable {
    let id = UUID()
    let label: String
    let filledCount: Int
    let color: Color
}

#Preview {








    InsightsView()
}
