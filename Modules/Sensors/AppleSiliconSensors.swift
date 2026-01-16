import Foundation
import Kit

internal func IOHIDEventFieldBase(_ type: Int32) -> Int32 {
    return type << 16
}

public func AppleSiliconSensors(_ page: Int32, _ usage: Int32, _ type: Int32) -> [String: Any]? {
    let dictionary: [String: Any] = [
        "PrimaryUsagePage": page,
        "PrimaryUsage": usage
    ]
    
    guard let system = IOHIDEventSystemClientCreate(kCFAllocatorDefault)?.takeRetainedValue() else {
        return [:]
    }
    
    IOHIDEventSystemClientSetMatching(system, dictionary as CFDictionary)
    let services = IOHIDEventSystemClientCopyServices(system)
    
    if services == nil {
        return [:]
    }
    
    let servicesArray = services as! [IOHIDServiceClient]
    var dict: [String: Any] = [:]
    
    for service in servicesArray {
        let nameRaw = IOHIDServiceClientCopyProperty(service, "Product" as CFString)
        let name = nameRaw != nil ? (nameRaw as! String) : nil
        
        let event = IOHIDServiceClientCopyEvent(service, Int64(type), 0, 0)
        if event == nil {
            continue
        }
        
        if let name = name, let event = event {
            let value = IOHIDEventGetFloatValue(event, IOHIDEventFieldBase(type))
            dict[name] = Double(value)
        }
    }
    
    return dict
}
