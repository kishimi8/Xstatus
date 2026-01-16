import SwiftUI
import GPU
import Kit

public class GPUStore: ObservableObject {
    @Published public var gpus: GPUs = GPUs()
    
    private var infoReader: InfoReader?
    
    public init() {
        self.infoReader = InfoReader(.GPU) { [weak self] value in
            DispatchQueue.main.async {
                if let value = value {
                    self?.gpus = value
                }
            }
        }
        
        self.start()
    }
    
    public func start() {
        self.infoReader?.start()
    }
    
    public func stop() {
        self.infoReader?.stop()
    }
}
