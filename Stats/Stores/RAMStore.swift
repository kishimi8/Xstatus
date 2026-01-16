import SwiftUI
import Kit
import RAM

public class RAMStore: ObservableObject {
    @Published public var usage: RAM_Usage? = nil
    @Published public var processes: [TopProcess] = []
    
    private var usageReader: UsageReader?
    private var processReader: RAM.ProcessReader?
    
    public init() {
        self.usageReader = UsageReader(.RAM) { [weak self] value in
            DispatchQueue.main.async {
                self?.usage = value
            }
        }
        
        self.processReader = RAM.ProcessReader(.RAM) { [weak self] value in
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
