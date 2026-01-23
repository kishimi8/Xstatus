//
//  popup.swift
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

internal class VirtualizationPopup: PopupWrapper {
    private let stackView: NSStackView = NSStackView()
    
    public init(_ module: ModuleType) {
        super.init(module, frame: NSRect(x: 0, y: 0, width: 200, height: 100))
        
        self.stackView.orientation = .vertical
        self.stackView.spacing = 0
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.stackView)
        
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setup(_ list: Containers_List) {
        self.stackView.subviews.forEach { $0.removeFromSuperview() }
        
        if list.isEmpty {
            let label = NSTextField(labelWithString: "No containers running")
            label.font = NSFont.systemFont(ofSize: 12)
            label.textColor = .secondaryLabelColor
            self.stackView.addArrangedSubview(label)
            return
        }
        
        for container in list {
            let containerStack = NSStackView()
            containerStack.orientation = .vertical
            containerStack.alignment = .leading
            containerStack.spacing = 2
            
            // Top row: Name and State
            let headerStack = NSStackView()
            headerStack.orientation = .horizontal
            headerStack.spacing = 4
            
            let name = NSTextField(labelWithString: container.names.first?.replacingOccurrences(of: "/", with: "") ?? "Unknown")
            name.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
            name.lineBreakMode = .byTruncatingTail
            
            let state = NSTextField(labelWithString: "(\(container.state))")
            state.font = NSFont.systemFont(ofSize: 10)
            state.textColor = container.state == "running" ? .systemGreen : .secondaryLabelColor
            
            headerStack.addArrangedSubview(name)
            headerStack.addArrangedSubview(state)
            
            // Middle row: CPU and RAM stats
            let statsStack = NSStackView()
            statsStack.orientation = .horizontal
            statsStack.spacing = 8
            
            let cpuLabel = NSTextField(labelWithString: container.cpu != nil ? String(format: "CPU: %.1f%%", container.cpu!) : "CPU: -")
            cpuLabel.font = NSFont.systemFont(ofSize: 10)
            cpuLabel.textColor = .secondaryLabelColor
            
            let ramLabel = NSTextField(labelWithString: container.ram != nil ? "RAM: \(Units(bytes: container.ram!).getReadableMemory())" : "RAM: -")
            ramLabel.font = NSFont.systemFont(ofSize: 10)
            ramLabel.textColor = .secondaryLabelColor
            
            statsStack.addArrangedSubview(cpuLabel)
            statsStack.addArrangedSubview(ramLabel)
            
            containerStack.addArrangedSubview(headerStack)
            containerStack.addArrangedSubview(statsStack)
            
            // Ports row
            if !container.ports.isEmpty {
                let portsDesc = container.ports.map { port in
                    if let publicPort = port.publicPort {
                        return "\(publicPort):\(port.privatePort)"
                    } else {
                        return "\(port.privatePort)"
                    }
                }.joined(separator: ", ")
                let portsLabel = NSTextField(labelWithString: "Ports: \(portsDesc)")
                portsLabel.font = NSFont.systemFont(ofSize: 9)
                portsLabel.textColor = .tertiaryLabelColor
                portsLabel.lineBreakMode = .byWordWrapping
                containerStack.addArrangedSubview(portsLabel)
            }
            
            self.stackView.addArrangedSubview(containerStack)
            
            // Add a small divider if not the last item
            if container.id != list.last?.id {
                let divider = NSView()
                divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
                divider.wantsLayer = true
                divider.layer?.backgroundColor = NSColor.separatorColor.cgColor
                divider.translatesAutoresizingMaskIntoConstraints = false
                divider.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
                self.stackView.addArrangedSubview(divider)
            }
        }
    }
}
