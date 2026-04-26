import SwiftUI
import Charts

struct InsightsView: View {
    @State private var selectedTab: TabItem = .insights
    @State private var appeared = false
    @State private var cycleScrollOffset = 0
    @State private var visibleStartIndex = 0

    private let stabilityData = [
        StabilityDatum(month: "Jan", lower: 24.0, center: 24.5, upper: 25.0),
        StabilityDatum(month: "Feb", lower: 24.2, center: 25.0, upper: 26.5),
        StabilityDatum(month: "Mar", lower: 26.5, center: 28.0, upper: 30.5),
        StabilityDatum(month: "Apr", lower: 27.5, center: 30.0, upper: 32.0)
    ]

    private let cycleTrends = [
        CycleTrendDatum(month: "Jan", value: 28),
        CycleTrendDatum(month: "Feb", value: 30),
        CycleTrendDatum(month: "Mar", value: 28),
        CycleTrendDatum(month: "Apr", value: 32),
        CycleTrendDatum(month: "May", value: 28),
        CycleTrendDatum(month: "Jun", value: 28)
    ]

    private let weightData = [
        WeightDatum(month: "Jan", value: 30),
        WeightDatum(month: "Feb", value: 42),
        WeightDatum(month: "Mar", value: 55),
        WeightDatum(month: "Apr", value: 74),
        WeightDatum(month: "May", value: 58)
    ]

    private let symptoms: [DonutSegment] = [
        DonutSegment(name: "Mood",     value: 30, color: Color(hex: "F2A0A8")),
        DonutSegment(name: "Bloating", value: 31, color: Color(hex: "B8B0D8")),
        DonutSegment(name: "Fatigue",  value: 21, color: Color(hex: "E87070")),
        DonutSegment(name: "Acne",     value: 17, color: Color(hex: "A8C8B8"))
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    switch selectedTab {
                    case .insights:
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 16) {
                                TopNavigationBar(topInset: geometry.safeAreaInsets.top, title: "Insights")

                                SectionHeader(title: "Stability Summary")
                                    .entranceMotion(index: 0, appeared: appeared)
                                StabilitySummaryCard(data: stabilityData)
                                    .entranceMotion(index: 1, appeared: appeared)

                                SectionHeader(title: "Cycle Trends")
                                    .entranceMotion(index: 2, appeared: appeared)
                                CycleTrendsSection(
                                    data: cycleTrends,
                                    cycleScrollOffset: $cycleScrollOffset,
                                    visibleStartIndex: $visibleStartIndex
                                )
                                .entranceMotion(index: 3, appeared: appeared)

                                SectionHeader(title: "Body & Metabolic Trends")
                                    .entranceMotion(index: 4, appeared: appeared)
                                WeightChartCard(data: weightData)
                                    .entranceMotion(index: 5, appeared: appeared)

                                SectionHeader(title: "Body Signals")
                                    .entranceMotion(index: 6, appeared: appeared)
                                SymptomDonutCard(segments: symptoms)
                                    .entranceMotion(index: 7, appeared: appeared)

                                SectionHeader(title: "Lifestyle Impact")
                                    .entranceMotion(index: 8, appeared: appeared)
                                LifestyleImpactCard()
                                    .entranceMotion(index: 9, appeared: appeared)
                                    .padding(.bottom, 110)
                            }
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .top)
                        }
                    case .home, .track:
                        PlaceholderTabView(topInset: geometry.safeAreaInsets.top, title: selectedTab.title)
                    }
                }

                // ── Bottom Tab Bar ──────────────────────────────────────
                HStack(spacing: 0) {
                    ForEach(TabItem.allCases, id: \.self) { item in
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = item
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: item.icon)
                                    .font(.system(size: 22))
                                    .scaleEffect(selectedTab == item ? 1.1 : 1.0)
                                    .animation(
                                        .spring(response: 0.3, dampingFraction: 0.6),
                                        value: selectedTab
                                    )
                                Text(item.title)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(selectedTab == item ? .darkText : .subText)
                        }
                        Spacer()
                    }

                    // Large + action button
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.darkText)
                            .frame(width: 50, height: 50)
                            .background(Color(hex: "EBEBEB"))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom : 12)
                .background(
                    Color.white
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 20, bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0, topTrailingRadius: 20
                            )
                        )
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Data Models

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

private struct DonutSegment: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
}

private struct LifestyleRow: Identifiable {
    let id = UUID()
    let label: String
    let filledCount: Int
    let color: Color
}

// MARK: - Top Nav

private struct TopNavigationBar: View {
    let topInset: CGFloat
    let title: String

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "FCE8E8").opacity(0.7), Color(hex: "F2F2F7")],
                startPoint: .top, endPoint: .bottom
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
                Color.clear.frame(width: 20, height: 20)
            }
            .padding(.vertical, 8)
        }
        .frame(height: 50)
    }
}

private struct DotGridLogo: View {
    private let colors: [Color] = [.lavenderPrimary, .softPink, .mintGreen, .accentPurple]
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                ForEach(0..<2, id: \.self) { Circle().fill(colors[$0]).frame(width: 8, height: 8) }
            }
            HStack(spacing: 2) {
                ForEach(2..<4, id: \.self) { Circle().fill(colors[$0]).frame(width: 8, height: 8) }
            }
        }
        .frame(width: 20, height: 20)
    }
}

private struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.darkText)
            .padding(.top, 8).padding(.bottom, 4)
    }
}

// MARK: - Stability Summary Card

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
                // Confidence band
                ForEach(data) { item in
                    AreaMark(
                        x: .value("Month", item.month),
                        yStart: .value("Lower", item.lower),
                        yEnd: .value("Upper", item.upper)
                    )
                    .foregroundStyle(Color.lavenderPrimary.opacity(0.28))
                    .interpolationMethod(.catmullRom)
                }
                // Center line
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
            .clipped()
            .chartYScale(domain: 23...33)
            .chartXAxis {
                AxisMarks(values: data.map(\.month)) { value in
                    AxisValueLabel {
                        if let m = value.as(String.self) {
                            Text(m)
                                .font(.system(size: 12, weight: m == "Mar" ? .bold : .regular))
                                .foregroundColor(m == "Mar" ? .darkText : .subText)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [24, 28, 32]) { value in
                    AxisValueLabel {
                        if let d = value.as(Int.self) {
                            Text("\(d)d").font(.system(size: 12)).foregroundColor(.subText)
                        }
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    // Tooltip at Mar (index 2)
                    let marMonth = data[2].month
                    let marCenter = data[2].center
                    if let x = proxy.position(forX: marMonth),
                       let y = proxy.position(forY: marCenter) {

                        // Tooltip bubble
                        VStack(spacing: 0) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 9, weight: .bold))
                                Text("Stability Improving")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(6)

                            Triangle()
                                .fill(Color.black)
                                .frame(width: 8, height: 5)
                        }
                        .position(x: x, y: y - 26)

                        // Dashed vertical line from dot to x-axis
                        Path { p in
                            p.move(to: CGPoint(x: x, y: y + 6))
                            p.addLine(to: CGPoint(x: x, y: geo.size.height))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundColor(Color.gray.opacity(0.45))

                        // Teal dot at data point
                        Circle()
                            .fill(Color(hex: "5E8B7E"))
                            .frame(width: 10, height: 10)
                            .position(x: x, y: y)
                    }
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Cycle Trends

private struct CycleTrendsSection: View {
    let data: [CycleTrendDatum]
    @Binding var cycleScrollOffset: Int
    @Binding var visibleStartIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            // Left arrow
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
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

            // Bars
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(data) { item in
                            CycleTrendBar(datum: item).id(item.id)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 6)
                }
                .frame(maxWidth: .infinity)
                .onAppear {
                    proxy.scrollTo(data[0].id, anchor: .leading)
                }
                .onChange(of: visibleStartIndex) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(data[newValue].id, anchor: .leading)
                    }
                }
            }

            // Right arrow
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
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
                // Full lavender pill — entire bar height
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(hex: "C4BCE0").opacity(0.55))
                    .frame(width: 48, height: 190)

                // Pink bottom — only 28pt (small sliver at bottom)
                UnevenRoundedRectangle(
                    topLeadingRadius: 0, bottomLeadingRadius: 22,
                    bottomTrailingRadius: 22, topTrailingRadius: 0
                )
                .fill(Color(hex: "F2A0A8"))
                .frame(width: 48, height: 28)

                // Gear circle — sits at bottom of lavender / top of pink junction
                // offset(y: -28) means bottom of circle aligns with top of pink section
                Circle()
                    .fill(Color(hex: "5E8B7E"))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 17))
                    )
                    .offset(y: -28)
            }
            .frame(width: 48, height: 190)

            Text(datum.month)
                .font(.system(size: 12))
                .foregroundColor(.subText)
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in state = true }
        )
    }
}

// MARK: - Weight Chart Card

private struct WeightChartCard: View {
    let data: [WeightDatum]
    @State private var selectedPeriod = "Monthly"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your weight")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.darkText)
                    Text("in kg")
                        .font(.system(size: 12))
                        .foregroundColor(.subText)
                }
                Spacer()
                // Monthly / Weekly toggle
                HStack(spacing: 0) {
                    ForEach(["Monthly", "Weekly"], id: \.self) { period in
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                selectedPeriod = period
                            }
                        }) {
                            Text(period)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(selectedPeriod == period ? .white : .darkText)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(
                                    selectedPeriod == period ? Color.black : Color.clear
                                )
                                .cornerRadius(20)
                        }
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(22)
            }

            // Chart
            Chart {
                ForEach(data) { item in
                    AreaMark(
                        x: .value("Month", item.month),
                        y: .value("Weight", item.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.softPink.opacity(0.45), Color.softPink.opacity(0.0)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Month", item.month),
                        y: .value("Weight", item.value)
                    )
                    .foregroundStyle(Color.softPink)
                    .lineStyle(.init(lineWidth: 2))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Month", item.month),
                        y: .value("Weight", item.value)
                    )
                    .symbolSize(35)
                    .foregroundStyle(Color.white)
                    .annotation(position: .overlay) {
                        Circle()
                            .stroke(Color.softPink, lineWidth: 2)
                            .frame(width: 8, height: 8)
                    }
                }
                RuleMark(y: .value("Ref", 50))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundStyle(Color.gray.opacity(0.4))
            }
            .frame(height: 160)
            .chartYScale(domain: 25...80)
            .chartYAxis {
                AxisMarks(position: .leading, values: [25, 50, 75]) { value in
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("\(v)").font(.system(size: 11)).foregroundColor(.subText)
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.gray.opacity(0.2))
                }
            }
            .chartXAxis {
                AxisMarks(values: data.map(\.month)) { value in
                    AxisValueLabel {
                        if let m = value.as(String.self) {
                            Text(m).font(.system(size: 11)).foregroundColor(.subText)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Symptom Donut Card

private struct SymptomDonutCard: View {
    let segments: [DonutSegment]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Symptom Trends")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.darkText)
                Text("Compared to last cycle")
                    .font(.system(size: 13))
                    .foregroundColor(.subText)
            }

            // Donut — fixed 300×300 container so labels never overflow card
            ZStack {
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let outerR: CGFloat = 85
                    let innerR: CGFloat = 52
                    var startAngle = Angle.degrees(-90)

                    for segment in segments {
                        let gap = Angle.degrees(2.5)
                        let sweep = Angle.degrees((segment.value / 100) * 360)
                        let endAngle = startAngle + sweep - gap

                        var path = Path()
                        path.addArc(center: center, radius: outerR,
                                    startAngle: startAngle, endAngle: endAngle,
                                    clockwise: false)
                        path.addArc(center: center, radius: innerR,
                                    startAngle: endAngle, endAngle: startAngle,
                                    clockwise: true)
                        path.closeSubpath()
                        context.fill(path, with: .color(segment.color))
                        startAngle = startAngle + sweep
                    }
                }
                .frame(width: 240, height: 240)

                // White hole
                Circle()
                    .fill(Color.white)
                    .frame(width: 104, height: 104)

                // Floating labels
                ForEach(labelPositions(containerSize: 300, ringCenter: 150, outerR: 85),
                        id: \.name) { item in
                    VStack(spacing: 1) {
                        Text(item.percent)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.darkText)
                        Text(item.name)
                            .font(.system(size: 11))
                            .foregroundColor(.subText)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .position(x: item.x, y: item.y)
                }
            }
            .frame(width: 300, height: 300)
            .frame(maxWidth: .infinity) // center in card
        }
        .cardStyle()
    }

    private struct LabelItem {
        let name: String; let percent: String
        let x: CGFloat;   let y: CGFloat
    }

    private func labelPositions(containerSize: CGFloat, ringCenter: CGFloat, outerR: CGFloat) -> [LabelItem] {
        let labelR = outerR + 55
        var result: [LabelItem] = []
        var currentAngle = -90.0

        for segment in segments {
            let sweep = (segment.value / 100.0) * 360.0
            let mid = currentAngle + sweep / 2.0
            let rad = mid * .pi / 180.0
            result.append(LabelItem(
                name: segment.name,
                percent: "\(Int(segment.value))%",
                x: ringCenter + labelR * cos(rad),
                y: ringCenter + labelR * sin(rad)
            ))
            currentAngle += sweep
        }
        return result
    }
}

// MARK: - Lifestyle Impact Card

private struct LifestyleImpactCard: View {
    @State private var tappedCell: String? = nil

    private let rows = [
        LifestyleRow(label: "Sleep",    filledCount: 7, color: .lavenderPrimary),
        LifestyleRow(label: "Hydrate",  filledCount: 4, color: .softPink),
        LifestyleRow(label: "Caffeine", filledCount: 5, color: .mintGreen),
        LifestyleRow(label: "Exercise", filledCount: 4, color: .softPink)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Correlation Strength")
                    .font(.headline)
                    .foregroundColor(.darkText)
                Spacer()
                HStack(spacing: 4) {
                    Text("4 months").font(.subheadline)
                    Image(systemName: "chevron.down").font(.caption)
                }
                .foregroundColor(.darkText)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.4)))
            }

            // Grid rows
            VStack(alignment: .leading, spacing: 10) {
                ForEach(rows) { row in
                    HStack(spacing: 4) {
                        Text(row.label)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.subText)
                            .frame(width: 65, alignment: .leading)

                        HStack(spacing: 3) {
                            ForEach(0..<10, id: \.self) { index in
                                HeatmapCell(
                                    id: "\(row.label)-\(index)",
                                    color: row.color,
                                    isFilled: index < row.filledCount,
                                    tappedCell: $tappedCell
                                )
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .cardStyle()
    }
}

private struct HeatmapCell: View {
    let id: String
    let color: Color
    let isFilled: Bool
    @Binding var tappedCell: String?

    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(isFilled ? color : color.opacity(0.1))
            .overlay {
                if isFilled {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.clear],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                }
            }
            .frame(width: 24, height: 24)
            .scaleEffect(tappedCell == id ? 1.2 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: tappedCell)
            .onTapGesture {
                tappedCell = id
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    if tappedCell == id { tappedCell = nil }
                }
            }
    }
}

// MARK: - Placeholder Tabs

private struct PlaceholderTabView: View {
    let topInset: CGFloat
    let title: String

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                TopNavigationBar(topInset: topInset, title: title)

                SectionHeader(title: "Recent Activity")
                ForEach(0..<3) { _ in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 48, height: 48)
                        VStack(alignment: .leading, spacing: 4) {
                            Rectangle().fill(Color.gray.opacity(0.2)).frame(width: 120, height: 12)
                            Rectangle().fill(Color.gray.opacity(0.1)).frame(width: 80, height: 10)
                        }
                        Spacer()
                    }
                    .cardStyle()
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(Color.appBackground)
    }
}

// MARK: - Tab Enum

private enum TabItem: Int, CaseIterable {
    case home, track, insights

    var title: String {
        switch self {
        case .home:     return "Home"
        case .track:    return "Track"
        case .insights: return "Insights"
        }
    }

    var icon: String {
        switch self {
        case .home:     return "house.fill"
        case .track:    return "clock"
        case .insights: return "chart.bar.fill"
        }
    }
}

// MARK: - View Modifiers

private extension View {
    func cardStyle() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardWhite)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
    }

    func entranceMotion(index: Int, appeared: Bool) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.08), value: appeared)
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let a: UInt64; let r: UInt64; let g: UInt64; let b: UInt64
        switch cleaned.count {
        case 6: (a, r, g, b) = (255, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
        case 8: (a, r, g, b) = ((value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }

    static let appBackground  = Color(hex: "F2F2F7")
    static let cardWhite      = Color.white
    static let lavenderPrimary = Color(hex: "B8B0D8")
    static let lavenderLight  = Color(hex: "D4CEEC")
    static let softPink       = Color(hex: "F2A0A8")
    static let mintGreen      = Color(hex: "A8C8B8")
    static let darkTeal       = Color(hex: "5E8B7E")
    static let darkText       = Color(hex: "1C1C1E")
    static let subText        = Color(hex: "8E8E93")
    static let accentPurple   = Color(hex: "8B7DB8")
}

#Preview { InsightsView() }