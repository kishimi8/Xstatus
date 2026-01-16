import SwiftUI
import Kit

struct RAMStatsView: View {
    @ObservedObject var store: RAMStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                GlassLabel("Memory", systemImage: "memorychip", color: .purple)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.0f%%", (store.usage?.usage ?? 0) * 100))
                    .font(.system(.title3, design: .rounded))
                    .bold()
            }
            
            if let usage = store.usage {
                LiquidUsageBar(value: usage.usage, colors: [.purple, .blue])
                    .frame(height: 12)
                
                VStack(alignment: .leading, spacing: 8) {
                    GlassValueRow(label: "Used", value: Units(bytes: Int64(usage.used)).getReadableMemory(), icon: "chart.bar.fill")
                    GlassValueRow(label: "Free", value: Units(bytes: Int64(usage.free)).getReadableMemory(), icon: "leaf")
                    GlassValueRow(label: "App", value: Units(bytes: Int64(usage.app)).getReadableMemory(), icon: "app")
                    GlassValueRow(label: "Compressed", value: Units(bytes: Int64(usage.compressed)).getReadableMemory(), icon: "archivebox")
                }
                
                if let pressure = usage.pressure {
                    HStack {
                        Text("Pressure")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Circle()
                            .fill(pressureColor(pressure))
                            .frame(width: 8, height: 8)
                        Text(pressure.rawValue.capitalized)
                            .font(.caption)
                            .bold()
                            .foregroundColor(pressureColor(pressure))
                    }
                    .padding(.top, 4)
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
                        Text(Units(bytes: Int64(process.usage)).getReadableMemory())
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
    
    private func pressureColor(_ pressure: RAMPressure) -> Color {
        switch pressure {
        case .normal: return .green
        case .warning: return .yellow
        case .critical: return .red
        }
    }
}
