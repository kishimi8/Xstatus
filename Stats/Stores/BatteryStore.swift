import SwiftUI
import Kit
import Battery

public class BatteryStore: ObservableObject {
    @Published public var usage: Battery_Usage? = nil
    @Published public var processes: [TopProcess] = []
    
    private var usageReader: UsageReader?
    private var processReader: Battery.ProcessReader?
    
    public init() {
        self.usageReader = UsageReader(.battery) { [weak self] value in
            DispatchQueue.main.async {
                self?.usage = value
            }
        }
        
        self.processReader = Battery.ProcessReader(.battery) { [weak self] value in
            DispatchQueue.main.async {
                self?.processes = value ?? []
            }
        }
        
        self.start()
    }
    
    public func start() {
        self.usageReader?.start()
        self.processReader?.start()
    }
    
    public func stop() {
        self.usageReader?.stop()
        self.processReader?.stop()
    }
}
