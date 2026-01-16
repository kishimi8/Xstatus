import SwiftUI
import Battery
import Kit

struct BatteryStatsView: View {
    @ObservedObject var store: BatteryStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let usage = store.usage {
                HStack {
                    GlassLabel("Battery", systemImage: batterySystemIcon(usage: usage), color: levelColor(usage: usage))
                        .font(.headline)
                    Spacer()
                    if usage.isCharging {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                            .font(.title3)
                            .shadow(color: .yellow, radius: 2)
                    }
                    Text(String(format: "%.0f%%", usage.level * 100))
                        .font(.system(.title3, design: .rounded))
                        .bold()
                }
                
                LiquidUsageBar(value: usage.level, colors: [levelColor(usage: usage), levelColor(usage: usage).opacity(0.6)])
                    .frame(height: 12)
                
                VStack(alignment: .leading, spacing: 8) {
                    GlassValueRow(label: "Source", value: usage.powerSource, icon: "bolt.circle")
                    GlassValueRow(label: "Health", value: "\(usage.health)%", icon: "heart.fill")
                    GlassValueRow(label: "Cycles", value: "\(usage.cycles)", icon: "arrow.2.circlepath")
                    if usage.temperature > 0 {
                        GlassValueRow(label: "Temp", value: String(format: "%.1f°C", usage.temperature), icon: "thermometer.medium")
                    }
                }
                
                if !store.processes.isEmpty {
                    Divider()
                        .opacity(0.3)
                    
                    Text("Top Energy Consumers")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    ForEach(store.processes.prefix(3), id: \.pid) { process in
                        HStack {
                            Text(process.name)
                                .lineLimit(1)
                                .font(.system(.caption, design: .rounded))
                            Spacer()
                            Text(String(format: "%.1f", process.usage))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(width: 260)
        .glassBackground()
    }
    
    private func levelColor(usage: Battery_Usage) -> Color {
        if usage.isCharging { return .green }
        if usage.level < 0.15 { return .red }
        if usage.level < 0.3 { return .orange }
        return .blue
    }
    
    private func batterySystemIcon(usage: Battery_Usage) -> String {
        if usage.level < 0.1 { return "battery.0" }
        if usage.level < 0.25 { return "battery.25" }
        if usage.level < 0.5 { return "battery.50" }
        if usage.level < 0.75 { return "battery.75" }
        return "battery.100"
    }
}
