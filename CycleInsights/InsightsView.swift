import SwiftUI
import Charts

struct InsightsView: View {
    @State private var selectedTab: TabItem = .insights
    @State private var appeared = false
    @State private var cycleScrollOffset = 0
    @State private var visibleStartIndex = 0

    private let stabilityData = [
        StabilityDatum(month: "Jan", lower: 26, center: 28, upper: 30),
        StabilityDatum(month: "Feb", lower: 25, center: 27, upper: 29),
        StabilityDatum(month: "Mar", lower: 27, center: 29, upper: 31),
        StabilityDatum(month: "Apr", lower: 26, center: 28, upper: 30),
        StabilityDatum(month: "May", lower: 28, center: 30, upper: 32)
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
        DonutSegment(name: "Mood",     value: 30, color: Color(hex:"F2A0A8")),
        DonutSegment(name: "Bloating", value: 31, color: Color(hex:"B8B0D8")),
        DonutSegment(name: "Fatigue",  value: 21, color: Color(hex:"E87070")),
        DonutSegment(name: "Acne",     value: 17, color: Color(hex:"A8C8B8"))
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    TabView(selection: $selectedTab) {
                        switch selectedTab {
                        case .insights:
                            ScrollView(showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 16) {
                                    TopNavigationBar(topInset: geometry.safeAreaInsets.top, title: selectedTab.title)

                                    SectionHeader(title: "Stability Summary")
                                        .entranceMotion(index: 0, appeared: appeared)
                                    StabilitySummaryCard(data: stabilityData)
                                        .entranceMotion(index: 1, appeared: appeared)

                                    SectionHeader(title: "Cycle Trends")
                                        .entranceMotion(index: 2, appeared: appeared)
                                    CycleTrendsSection(data: cycleTrends, cycleScrollOffset: $cycleScrollOffset, visibleStartIndex: $visibleStartIndex)
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
                                        .padding(.bottom, 100)
                                }
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity, alignment: .top)
                            }
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                        case .home, .track:
                            PlaceholderTabView(topInset: geometry.safeAreaInsets.top, title: selectedTab.title)
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }

                // Custom Tab Bar
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
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), 
                                               value: selectedTab)
                                Text(item.title)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(selectedTab == item ? .darkText : .subText)
                        }
                        Spacer()
                    }

                    // Large + button (separate, not a tab)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom : 12)
                .background(
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .onAppear {
            appeared = true
        }
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
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            
                            Triangle()
                                .fill(Color.black)
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
    @State private var selectedPeriod = "Monthly"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
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
                HStack(spacing: 0) {
                    Button(action: { selectedPeriod = "Monthly" }) {
                        Text("Monthly")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedPeriod == "Monthly" ? .white : .darkText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                selectedPeriod == "Monthly" 
                                    ? Color.black 
                                    : Color.gray.opacity(0.1)
                            )
                            .cornerRadius(20)
                    }
                    Button(action: { selectedPeriod = "Weekly" }) {
                        Text("Weekly")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedPeriod == "Weekly" ? .white : .darkText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                selectedPeriod == "Weekly" 
                                    ? Color.black 
                                    : Color.gray.opacity(0.1)
                            )
                            .cornerRadius(20)
                    }
                }
                .background(Color.gray.opacity(0.08))
                .cornerRadius(22)
            }
            
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
                }
                ForEach(data) { item in
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
                    .symbolSize(40)
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

private struct SymptomDonutCard: View {
    let segments: [DonutSegment]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Symptom Trends")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.darkText)
                Text("Compared to last cycle")
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
            Text("\(Int(segment.value))%")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.darkText)
            Text(segment.name)
                .font(.system(size: 11))
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
        LifestyleRow(label: "Sleep",    filledCount: 7, color: .lavenderPrimary),
        LifestyleRow(label: "Hydrate",  filledCount: 4, color: .softPink),
        LifestyleRow(label: "Caffeine", filledCount: 5, color: .mintGreen),
        LifestyleRow(label: "Exercise", filledCount: 4, color: .softPink)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            controlsHeader

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
                                .frame(width: 24, height: 24)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
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

private struct PlaceholderTabView: View {
    let topInset: CGFloat
    let title: String

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                TopNavigationBar(topInset: topInset, title: title)

                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Summary")
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.lavenderPrimary.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(Image(systemName: "clock.fill").foregroundColor(.lavenderPrimary))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Next Phase")
                                    .font(.system(size: 14))
                                    .foregroundColor(.subText)
                                Text("Follicular in 3 days")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.darkText)
                            }
                        }
                    }
                    .cardStyle()

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
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(Color.appBackground)
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
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .frame(width: 24, height: 24)
            .scaleEffect(tappedCell == id ? 1.2 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: tappedCell)
            .onTapGesture {
                tappedCell = id
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    if tappedCell == id {
                        tappedCell = nil
                    }
                }
            }
    }
}

private struct LifestyleRow: Identifiable {
    let id = UUID()
    let label: String
    let filledCount: Int
    let color: Color
}

private enum TabItem: Int, CaseIterable {
    case home, track, insights
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .track: return "Track"
        case .insights: return "Insights"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .track: return "clock"
        case .insights: return "chart.bar.fill"
        }
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

private extension View {
    func entranceMotion(index: Int, appeared: Bool) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.08), value: appeared)
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
