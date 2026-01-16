import SwiftUI
import Bluetooth
import Kit

public class BluetoothStore: ObservableObject {
    @Published public var devices: [BLEDevice] = []
    
    private var devicesReader: DevicesReader?
    
    public init() {
        self.devicesReader = DevicesReader { [weak self] value in
            DispatchQueue.main.async {
                self?.devices = value ?? []
            }
        }
        
        self.start()
    }
    
    public func start() {
        self.devicesReader?.start()
    }
    
    public func stop() {
        self.devicesReader?.stop()
    }
}
