import SwiftUI
import GPU
import Kit

struct GPUStatsView: View {
    @ObservedObject var store: GPUStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassLabel("GPU", systemImage: "opticid", color: .pink)
                .font(.headline)
            
            ForEach(store.gpus.list, id: \.id) { gpu in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(gpu.model)
                            .font(.system(.subheadline, design: .rounded))
                            .bold()
                            .lineLimit(1)
                        Spacer()
                        if !gpu.state {
                            Text("Asleep")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.secondary.opacity(0.1))
                                .cornerRadius(4)
                        } else if let utilization = gpu.utilization {
                            Text(String(format: "%.0f%%", utilization * 100))
                                .font(.system(.subheadline, design: .monospaced))
                                .bold()
                        }
                    }
                    
                    if gpu.state, let utilization = gpu.utilization {
                        LiquidUsageBar(value: utilization, colors: [.pink, .purple])
                            .frame(height: 10)
                        
                        HStack(spacing: 16) {
                            if let temp = gpu.temperature {
                                GlassValueRow(label: "Temp", value: "\(Int(temp))°C", icon: "thermometer.medium")
                            }
                            if let freq = gpu.coreClock {
                                GlassValueRow(label: "Freq", value: "\(freq)MHz", icon: "bolt.fill")
                            }
                        }
                    }
                }
                if gpu.id != store.gpus.list.last?.id {
                   Divider()
                        .opacity(0.3)
                }
            }
        }
        .padding()
        .frame(width: 260)
        .glassBackground()
    }
}
