import SwiftUI
import Kit

@main
struct StatsApp: App {
    @StateObject var cpuStore = CPUStore()
    @StateObject var ramStore = RAMStore()
    @StateObject var diskStore = DiskStore()
    @StateObject var batteryStore = BatteryStore()
    @StateObject var networkStore = NetworkStore()
    @StateObject var gpuStore = GPUStore()
    @StateObject var bluetoothStore = BluetoothStore()
    @StateObject var clockStore = ClockStore()
    @StateObject var sensorsStore = SensorsStore()
    
    var body: some Scene {
        // CPU
        MenuBarExtra {
            CPUStatsView(store: cpuStore)
        } label: {
            HStack {
                Image(systemName: "cpu")
                Text(String(format: "%.0f%%", cpuStore.load.totalUsage * 100))
            }
        }
        .menuBarExtraStyle(.window)
        
        // RAM
        MenuBarExtra {
            RAMStatsView(store: ramStore)
        } label: {
            HStack {
                Image(systemName: "memorychip")
                Text(String(format: "%.0f%%", (ramStore.usage?.usage ?? 0) * 100))
            }
        }
        .menuBarExtraStyle(.window)
        
        // Disk
        MenuBarExtra {
            DiskStatsView(store: diskStore)
        } label: {
            HStack {
                Image(systemName: "internaldrive")
                if let root = diskStore.disks.first(where: { $0.root }) {
                    Text(String(format: "%.0f%%", root.percentage * 100))
                }
            }
        }
        .menuBarExtraStyle(.window)
        
        // Battery
        MenuBarExtra {
            BatteryStatsView(store: batteryStore)
        } label: {
            HStack {
                Image(systemName: batteryIcon(level: batteryStore.usage?.level ?? 0, isCharging: batteryStore.usage?.isCharging ?? false))
                Text(String(format: "%.0f%%", (batteryStore.usage?.level ?? 0) * 100))
            }
        }
        .menuBarExtraStyle(.window)
        
        // Network
        MenuBarExtra {
            NetworkStatsView(store: networkStore)
        } label: {
            HStack {
                Image(systemName: "network")
                Text(Units(bytes: networkStore.usage.bandwidth.download + networkStore.usage.bandwidth.upload).getReadableSpeed())
            }
        }
        .menuBarExtraStyle(.window)
        
        // GPU
        MenuBarExtra {
            GPUStatsView(store: gpuStore)
        } label: {
            HStack {
                Image(systemName: "opticid")
                if let gpu = gpuStore.gpus.list.first(where: { $0.state }) {
                    Text(String(format: "%.0f%%", (gpu.utilization ?? 0) * 100))
                }
            }
        }
        .menuBarExtraStyle(.window)
        
        // Bluetooth
        MenuBarExtra {
            BluetoothStatsView(store: bluetoothStore)
        } label: {
            Image(systemName: "wave.3.left")
        }
        .menuBarExtraStyle(.window)
        
        // Sensors
        MenuBarExtra {
            SensorsStatsView(store: sensorsStore)
        } label: {
            Image(systemName: "gauge.medium")
        }
        .menuBarExtraStyle(.window)
        
        // Clock
        MenuBarExtra {
            ClockStatsView(store: clockStore)
        } label: {
            Text(clockStore.date, style: .time)
        }
        .menuBarExtraStyle(.window)
        
        Window("Settings", id: "settings") {
            Text("Stats Settings")
                .frame(width: 400, height: 300)
        }
        .background(.ultraThinMaterial)
    }
    
    private func batteryIcon(level: Double, isCharging: Bool) -> String {
        if isCharging { return "battery.100.bolt" }
        if level < 0.1 { return "battery.0" }
        if level < 0.25 { return "battery.25" }
        if level < 0.5 { return "battery.50" }
        if level < 0.75 { return "battery.75" }
        return "battery.100"
    }
}
