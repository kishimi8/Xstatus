import SwiftUI
import Sensors
import Kit

public class SensorsStore: ObservableObject {
    @Published public var sensors: [Sensor_p] = []
    @Published public var isHelperInstalled: Bool = false
    
    private var sensorsReader: SensorsReader?
    
    public init() {
        self.sensorsReader = SensorsReader { [weak self] value in
            DispatchQueue.main.async {
                self?.sensors = value?.sensors ?? []
                self?.isHelperInstalled = SMCHelper.shared.isInstalled
            }
        }
        
        self.start()
        
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            self.resetFans()
        }
    }
    
    public func start() {
        self.sensorsReader?.start()
    }
    
    public func stop() {
        self.sensorsReader?.stop()
        self.resetFans()
    }
    
    public func setFanMode(id: Int, mode: FanMode) {
        if !self.isHelperInstalled {
            SMCHelper.shared.install { installed in
                if installed {
                    DispatchQueue.main.async { self.isHelperInstalled = true }
                    SMCHelper.shared.setFanMode(id, mode: mode.rawValue)
                }
            }
        } else {
            SMCHelper.shared.setFanMode(id, mode: mode.rawValue)
        }
    }
    
    public func setFanSpeed(id: Int, speed: Int) {
        if self.isHelperInstalled {
            SMCHelper.shared.setFanSpeed(id, speed: speed)
        }
    }
    
    public func resetFans() {
        if self.isHelperInstalled {
            if let count = SMC.shared.getValue("FNum") {
                for i in 0..<Int(count) {
                    SMCHelper.shared.setFanMode(i, mode: FanMode.automatic.rawValue)
                }
            }
        }
    }
}
