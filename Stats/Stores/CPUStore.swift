import SwiftUI
import Kit
import CPU

public class CPUStore: ObservableObject {
    @Published public var load: CPU_Load = CPU_Load()
    @Published public var processes: [TopProcess] = []
    @Published public var temperature: Double? = nil
    @Published public var frequency: CPU_Frequency? = nil
    
    private var loadReader: LoadReader?
    private var processReader: ProcessReader?
    private var temperatureReader: TemperatureReader?
    private var frequencyReader: FrequencyReader?
    
    public init() {
        self.loadReader = LoadReader(.CPU) { [weak self] value in
            DispatchQueue.main.async {
                if let value = value {
                    self?.load = value
                }
            }
        }
        
        self.processReader = ProcessReader(.CPU) { [weak self] value in
            DispatchQueue.main.async {
                self?.processes = value
            }
        }
        
        self.temperatureReader = TemperatureReader(.CPU) { [weak self] value in
            DispatchQueue.main.async {
                self?.temperature = value
            }
        }
        
        #if !arch(x86_64)
        self.frequencyReader = FrequencyReader(.CPU) { [weak self] value in
            DispatchQueue.main.async {
                self?.frequency = value
            }
        }
        #endif
        
        self.start()
    }
    
    public func start() {
        self.loadReader?.start()
        self.processReader?.start()
        self.temperatureReader?.start()
        self.frequencyReader?.start()
    }
    
    public func stop() {
        self.loadReader?.stop()
        self.processReader?.stop()
        self.temperatureReader?.stop()
        self.frequencyReader?.stop()
    }
}
