//
//  settings.swift
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

internal class VirtualizationSettings: NSStackView, Settings_v {
    private var updateIntervalValue: Int = 1
    private let title: String
    
    public var setInterval: ((_ value: Int) -> Void) = {_ in }
    public var setSocketPath: ((_ value: String) -> Void) = {_ in }
    
    public init(_ module: ModuleType) {
        self.title = module.stringValue
        self.updateIntervalValue = Store.shared.int(key: "\(self.title)_updateInterval", defaultValue: self.updateIntervalValue)
        
        super.init(frame: NSRect.zero)
        
        self.orientation = .vertical
        self.distribution = .gravityAreas
        self.translatesAutoresizingMaskIntoConstraints = false
        self.spacing = Constants.Settings.margin
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func load(widgets: [widget_t]) {
        self.subviews.forEach{ $0.removeFromSuperview() }
        
        let socketPath = Store.shared.string(key: "DockerReader_socketPath", defaultValue: "/var/run/docker.sock")
        let socketPathField = NSTextField()
        socketPathField.stringValue = socketPath
        socketPathField.isEditable = true
        socketPathField.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        socketPathField.target = self
        socketPathField.action = #selector(self.changeSocketPath)
        
        let onlyRunning = Store.shared.bool(key: "Virtualization_onlyRunning", defaultValue: false)
        
        self.addArrangedSubview(PreferencesSection([
            PreferencesRow(localizedString("Update interval"), component: selectView(
                action: #selector(self.changeUpdateInterval),
                items: ReaderUpdateIntervals,
                selected: "\(self.updateIntervalValue)"
            )),
            PreferencesRow(localizedString("Socket path"), component: socketPathField),
            PreferencesRow(localizedString("Show only running containers"), component: switchView(
                action: #selector(self.toggleOnlyRunning),
                state: onlyRunning
            ))
        ]))
    }
    
    @objc private func changeUpdateInterval(_ sender: NSMenuItem) {
        guard let key = sender.representedObject as? String, let value = Int(key) else { return }
        self.updateIntervalValue = value
        Store.shared.set(key: "\(self.title)_updateInterval", value: value)
        self.setInterval(value)
    }
    
    @objc private func changeSocketPath(_ sender: NSTextField) {
        Store.shared.set(key: "DockerReader_socketPath", value: sender.stringValue)
        self.setSocketPath(sender.stringValue)
    }
    
    @objc private func toggleOnlyRunning(_ sender: NSSwitch) {
        Store.shared.set(key: "Virtualization_onlyRunning", value: sender.state == .on)
    }
}
