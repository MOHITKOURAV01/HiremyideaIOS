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


#Preview {
    InsightsView()
}
