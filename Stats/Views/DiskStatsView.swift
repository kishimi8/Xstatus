import SwiftUI
import Kit

struct DiskStatsView: View {
    @ObservedObject var store: DiskStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassLabel("Disk", systemImage: "internaldrive", color: .orange)
                .font(.headline)
            
            ForEach(store.disks, id: \.id) { disk in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(disk.mediaName)
                            .font(.system(.subheadline, design: .rounded))
                            .bold()
                            .lineLimit(1)
                        Spacer()
                        Text(String(format: "%.0f%%", disk.percentage * 100))
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    LiquidUsageBar(value: disk.percentage, colors: [.orange, .yellow])
                        .frame(height: 10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        GlassValueRow(label: "Used", value: Units(bytes: Int64(disk.used)).getReadableMemory(), icon: "chart.pie.fill")
                        GlassValueRow(label: "Free", value: Units(bytes: Int64(disk.free)).getReadableMemory(), icon: "sparkles")
                    }
                    
                    HStack(spacing: 12) {
                        Label {
                            Text(Units(bytes: Int64(store.activity.read)).getReadableSpeed())
                                .font(.system(.caption2, design: .monospaced))
                        } icon: {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.blue)
                        }
                        
                        Label {
                            Text(Units(bytes: Int64(store.activity.write)).getReadableSpeed())
                                .font(.system(.caption2, design: .monospaced))
                        } icon: {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .font(.caption2)
                }
                if disk.id != store.disks.last?.id {
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
