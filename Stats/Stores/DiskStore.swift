import SwiftUI
import Kit
import Disk

public class DiskStore: ObservableObject {
    @Published public var disks: Disks = Disks()
    @Published public var processes: [Disk_process] = []
    
    private var capacityReader: CapacityReader?
    private var activityReader: ActivityReader?
    private var processReader: Disk.ProcessReader?
    
    public init() {
        self.capacityReader = CapacityReader(.disk) { [weak self] value in
            DispatchQueue.main.async {
                if let value = value {
                    self?.disks = value
                }
            }
        }
        
        self.activityReader = ActivityReader(.disk) { [weak self] value in
            DispatchQueue.main.async {
                if let value = value {
                    self?.disks = value
                }
            }
        }
        
        self.processReader = Disk.ProcessReader(.disk) { [weak self] value in
            DispatchQueue.main.async {
                self?.processes = value ?? []
            }
        }
        
        self.start()
    }
    
    public func start() {
        self.capacityReader?.start()
        self.activityReader?.start()
        self.processReader?.start()
    }
    
    public func stop() {
        self.capacityReader?.stop()
        self.activityReader?.stop()
        self.processReader?.stop()
    }
}
