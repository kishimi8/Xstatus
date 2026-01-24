//
//  Virtualization.swift
//  Virtualization
//
//  Created by Ibrahim Ishaq KISHIMI
//  Using Swift 6.0
//  Running on macOS 16
//
//  Copyright © 2026 IBRAHIM ISHAQ KISHIMI. All rights reserved.
//

import Cocoa
import Kit

public class Virtualization: Module {
    private let popupView: VirtualizationPopup
    private let settingsView: VirtualizationSettings
    private let portalView: VirtualizationPortal
    
    // Reader configuration
    private var dockerReader: DockerReader? = nil
    
    public init() {
        self.settingsView = VirtualizationSettings(.virtualization)
        self.popupView = VirtualizationPopup(.virtualization)
        self.portalView = VirtualizationPortal(.virtualization)
        
        super.init(
            moduleType: .virtualization,
            popup: self.popupView,
            settings: self.settingsView,
            portal: self.portalView
        )
        guard self.available else { return }
        
        self.dockerReader = DockerReader(.virtualization) { [weak self] value in
            self?.callback(value)
        }
        
        self.settingsView.setInterval = { [weak self] value in
            self?.dockerReader?.setInterval(value)
        }
        self.settingsView.setSocketPath = { [weak self] value in
            self?.dockerReader?.setSocketPath(value)
        }
        
        self.setReaders([self.dockerReader])
    }
    
    private func callback(_ value: Containers_List?) {
        guard let list = value, self.enabled else { return }
        
        if let data = try? JSONEncoder().encode(list) {
            self.userDefaults?.set(data, forKey: "Virtualization@DockerReader")
        }
        
        DispatchQueue.main.async {
            self.popupView.setup(list)
            
            // Update widgets
            self.menuBar.widgets.filter({ $0.isActive }).forEach { (w: SWidget) in
                switch w.item {
                case let widget as Mini:
                    widget.setSuffix("")
                    widget.setValue(Double(list.count) / 100.0)
                case let widget as StateWidget:
                    widget.setValue(!list.isEmpty)
                default: break
                }
            }
        }
    }
}
