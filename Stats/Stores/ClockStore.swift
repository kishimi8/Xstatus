import SwiftUI
import Clock
import Kit

public class ClockStore: ObservableObject {
    @Published public var date: Date = Date()
    @Published public var clocks: [Clock_t] = []
    
    private var reader: ClockReader?
    
    public init() {
        self.clocks = Clock.list
        
        self.reader = ClockReader(.clock) { [weak self] value in
            DispatchQueue.main.async {
                if let value = value {
                    self?.date = value
                    for i in 0..<(self?.clocks.count ?? 0) {
                        self?.clocks[i].value = value
                    }
                }
            }
        }
        
        self.start()
    }
    
    public func start() {
        self.reader?.start()
    }
    
    public func stop() {
        self.reader?.stop()
    }
}
