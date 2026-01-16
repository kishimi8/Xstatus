import SwiftUI
import Bluetooth
import Kit

struct BluetoothStatsView: View {
    @ObservedObject var store: BluetoothStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassLabel("Bluetooth", systemImage: "antenna.radiowaves.left.and.right", color: .blue)
                .font(.headline)
            
            if store.devices.filter({ $0.isConnected }).isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "bolt.horizontal.circle")
                            .font(.system(size: 24))
                        Text("No devices connected")
                            .font(.system(.caption, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(store.devices.filter{ $0.isConnected }, id: \.address) { device in
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(device.name)
                                    .font(.system(.subheadline, design: .rounded))
                                    .bold()
                                    .lineLimit(1)
                                if let rssi = device.RSSI {
                                    HStack(spacing: 4) {
                                        Image(systemName: "waveform.path.ecg")
                                            .font(.caption2)
                                        Text("\(rssi) dBm")
                                            .font(.system(size: 9, design: .monospaced))
                                    }
                                    .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                ForEach(device.batteryLevel, id: \.key) { level in
                                    HStack(spacing: 6) {
                                        Text(batteryLabel(level.key))
                                            .font(.system(size: 8, design: .rounded))
                                            .textCase(.uppercase)
                                            .foregroundColor(.secondary)
                                        
                                        BatteryIcon(value: Int(level.value) ?? 0)
                                            .frame(width: 18, height: 10)
                                        
                                        Text("\(level.value)%")
                                            .font(.system(.caption, design: .monospaced))
                                            .bold()
                                    }
                                }
                            }
                        }
                        if device.address != store.devices.filter{ $0.isConnected }.last?.address {
                            Divider()
                                .opacity(0.2)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 280)
        .glassBackground()
    }
    
    private func batteryLabel(_ key: String) -> String {
        key.replacingOccurrences(of: "device_batteryLevel", with: "")
           .replacingOccurrences(of: "BatteryPercent", with: "")
    }
}

struct BatteryIcon: View {
    let value: Int
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.primary.opacity(0.3), lineWidth: 1)
            
            RoundedRectangle(cornerRadius: 1)
                .fill(color)
                .padding(1)
                .frame(width: CGFloat(value) / 100 * 18)
        }
    }
    
    private var color: Color {
        if value < 20 { return .red }
        if value < 50 { return .orange }
        return .green
    }
}
