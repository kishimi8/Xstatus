import SwiftUI
import Kit

struct CPUStatsView: View {
    @ObservedObject var store: CPUStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                GlassLabel("CPU", systemImage: "cpu", color: .blue)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.0f%%", store.load.totalUsage * 100))
                    .font(.system(.title3, design: .rounded))
                    .bold()
            }
            
            LiquidUsageBar(value: store.load.totalUsage, colors: [.blue, .cyan])
                .frame(height: 12)
            
            VStack(alignment: .leading, spacing: 8) {
                GlassValueRow(label: "System", value: String(format: "%.1f%%", store.load.systemLoad * 100), icon: "gearshape")
                GlassValueRow(label: "User", value: String(format: "%.1f%%", store.load.userLoad * 100), icon: "person")
                if !store.temperatures.isEmpty {
                    GlassValueRow(label: "Temp", value: String(format: "%.0f°C", store.temperatures.first?.value ?? 0), icon: "thermometer.medium")
                }
            }
            
            if !store.processes.isEmpty {
                Divider()
                    .opacity(0.3)
                
                Text("Top Processes")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                ForEach(store.processes.prefix(3), id: \.pid) { process in
                    HStack {
                        Text(process.name)
                            .lineLimit(1)
                            .font(.system(.caption, design: .rounded))
                        Spacer()
                        Text(String(format: "%.1f%%", process.usage))
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .frame(width: 260)
        .glassBackground()
    }
}
