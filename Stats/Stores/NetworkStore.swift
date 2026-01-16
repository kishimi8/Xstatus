import SwiftUI
import Kit
import Net

public class NetworkStore: ObservableObject {
    @Published public var usage: Network_Usage = Network_Usage()
    @Published public var connectivity: Network_Connectivity? = nil
    @Published public var processes: [Network_Process] = []
    
    private var usageReader: UsageReader?
    private var processReader: Net.ProcessReader?
    private var connectivityReader: ConnectivityReader?
    
    public init() {
        self.usageReader = UsageReader(.network) { [weak self] value in
            DispatchQueue.main.async {
                if let value = value {
                    self?.usage = value
                }
            }
        }
        
        self.processReader = Net.ProcessReader(.network) { [weak self] value in
            DispatchQueue.main.async {
                self?.processes = value ?? []
            }
        }
        
        self.connectivityReader = ConnectivityReader(.network) { [weak self] value in
            DispatchQueue.main.async {
                self?.connectivity = value
            }
        }
        
        self.start()
    }
    
    public func start() {
        self.usageReader?.start()
        self.processReader?.start()
        self.connectivityReader?.start()
    }
    
    public func stop() {
        self.usageReader?.stop()
        self.processReader?.stop()
        self.connectivityReader?.stop()
    }
}
