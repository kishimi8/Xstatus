import SwiftUI
import Net
import Kit

struct NetworkStatsView: View {
    @ObservedObject var store: NetworkStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                GlassLabel("Network", systemImage: "network", color: .green)
                    .font(.headline)
                Spacer()
                if let interface = store.usage.interface {
                    Text(interface.displayName)
                        .font(.system(.caption2, design: .rounded))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.secondary.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            VStack(spacing: 12) {
                NetworkGlassRow(label: "Download", speed: store.usage.bandwidth.download, color: .blue, icon: "arrow.down.circle.fill")
                NetworkGlassRow(label: "Upload", speed: store.usage.bandwidth.upload, color: .green, icon: "arrow.up.circle.fill")
            }
            
            VStack(alignment: .leading, spacing: 6) {
                if let v4 = store.usage.laddr.v4 {
                    GlassValueRow(label: "Local IP", value: v4, icon: "house.fill")
                }
                if let publicIP = store.usage.raddr.v4 ?? store.usage.raddr.v6 {
                    GlassValueRow(label: "Public IP", value: publicIP, icon: "globe")
                }
                if let latency = store.connectivity?.latency {
                    GlassValueRow(label: "Latency", value: "\(Int(latency)) ms", icon: "timer")
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
                        HStack(spacing: 8) {
                            Text("D: \(Units(bytes: Int64(process.download)).getReadableSpeed())")
                            Text("U: \(Units(bytes: Int64(process.upload)).getReadableSpeed())")
                        }
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .frame(width: 265)
        .glassBackground()
    }
}

struct NetworkGlassRow: View {
    let label: String
    let speed: Int64
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(label)
                .font(.system(.caption, design: .rounded))
            Spacer()
            Text(Units(bytes: speed).getReadableSpeed())
                .font(.system(.subheadline, design: .monospaced))
                .bold()
        }
    }
}
