import SwiftUI
import Sensors
import Kit

struct SensorsStatsView: View {
    @ObservedObject var store: SensorsStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                GlassLabel("System Sensors", systemImage: "gauge.with.dots.needle.bottom.50percent", color: .indigo)
                    .font(.headline)
                Spacer()
                if store.sensors.contains(where: { $0.type == .fan }) {
                    Button {
                        store.resetFans()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .help("Reset all fans to automatic")
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Temperature Sensors
                    SensorSection(title: "Temperatures", icon: "thermometer.medium", color: .orange) {
                        ForEach(store.sensors.filter{ $0.type == .temperature }.prefix(15), id: \.key) { sensor in
                            GlassValueRow(label: sensor.name, value: sensor.formattedMiniValue)
                        }
                    }
                    
                    // Fans (Interactive)
                    let fanSensors = store.sensors.filter{ $0.type == .fan || $0 is Fan }
                    if !fanSensors.isEmpty {
                        SensorSection(title: "Fans", icon: "fan.fill", color: .blue) {
                            ForEach(fanSensors, id: \.key) { sensor in
                                if let fan = sensor as? Fan {
                                    FanControlRow(fan: fan, store: store)
                                } else {
                                    GlassValueRow(label: sensor.name, value: sensor.formattedMiniValue)
                                }
                            }
                        }
                    }
                    
                    // Power
                    SensorSection(title: "Power", icon: "bolt.fill", color: .yellow) {
                        ForEach(store.sensors.filter{ $0.type == .power }, id: \.key) { sensor in
                            GlassValueRow(label: sensor.name, value: sensor.formattedMiniValue)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 450)
        }
        .padding()
        .frame(width: 320)
        .glassBackground()
    }
}

struct FanControlRow: View {
    let fan: Fan
    @ObservedObject var store: SensorsStore
    
    @State private var manualSpeed: Double
    @State private var mode: FanMode
    
    init(fan: Fan, store: SensorsStore) {
        self.fan = fan
        self.store = store
        _manualSpeed = State(initialValue: Double(fan.customSpeed ?? Int(fan.value)))
        _mode = State(initialValue: fan.customMode ?? fan.mode)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(fan.name)
                    .font(.system(.caption, design: .rounded))
                    .bold()
                Spacer()
                Text("\(Int(fan.value)) RPM")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                
                GlassPicker(selection: $mode, options: [.automatic, .forced])
                    .onChange(of: mode) { newMode in
                        store.setFanMode(id: fan.id, mode: newMode)
                    }
            }
            
            if mode == .forced {
                HStack(spacing: 12) {
                    Image(systemName: "minus")
                        .font(.system(size: 8))
                        .onTapGesture { adjustSpeed(-100) }
                    
                    GlassSlider(value: $manualSpeed, range: fan.minSpeed...fan.maxSpeed, color: .blue)
                        .onChange(of: manualSpeed) { newValue in
                            store.setFanSpeed(id: fan.id, speed: Int(newValue))
                        }
                    
                    Image(systemName: "plus")
                        .font(.system(size: 8))
                        .onTapGesture { adjustSpeed(100) }
                }
                .padding(.horizontal, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                LiquidUsageBar(value: fan.value / fan.maxSpeed, colors: [.blue, .cyan])
                    .frame(height: 6)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func adjustSpeed(_ delta: Double) {
        let newValue = min(max(manualSpeed + delta, fan.minSpeed), fan.maxSpeed)
        manualSpeed = newValue
    }
}

extension FanMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .automatic: return "Auto"
        case .forced: return "Manual"
        }
    }
}
