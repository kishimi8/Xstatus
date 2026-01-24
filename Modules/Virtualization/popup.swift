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
    private let dashboardHeight: CGFloat = 90
    private let chartHeight: CGFloat = 120 + Constants.Popup.separatorHeight
    private let containerHeight: CGFloat = 32
    
    private var circle: PieChartView? = nil
    private var ramCircle: HalfCircleGraphView? = nil
    private var countCircle: HalfCircleGraphView? = nil
    private var lineChart: LineChartView? = nil
    
    private var initialized: Bool = false
    private var containersStack: NSStackView? = nil
    
    private var lineChartHistory: Int = 180
    
    public init(_ module: ModuleType) {
        super.init(module, frame: NSRect(x: 0, y: 0, width: Constants.Popup.width, height: 0))
        
        self.spacing = 0
        self.orientation = .vertical
        
        self.addArrangedSubview(self.initDashboard())
        self.addArrangedSubview(self.initChart())
        self.addArrangedSubview(self.initContainers())
        
        self.recalculateHeight()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func recalculateHeight() {
        var h: CGFloat = 0
        self.arrangedSubviews.forEach { v in
            if let v = v as? NSStackView {
                h += v.arrangedSubviews.map({ $0.bounds.height }).reduce(0, +)
            } else {
                h += v.bounds.height
            }
        }
        if self.frame.size.height != h {
            self.setFrameSize(NSSize(width: self.frame.width, height: h))
            self.sizeCallback?(self.frame.size)
        }
    }
    
    private func initDashboard() -> NSView {
        let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.dashboardHeight))
        view.heightAnchor.constraint(equalToConstant: view.bounds.height).isActive = true
        
        let usageSize = self.dashboardHeight - 20
        let usageX = (view.frame.width - usageSize) / 2
        
        let usage = NSView(frame: NSRect(x: usageX, y: (view.frame.height - usageSize) / 2, width: usageSize, height: usageSize))
        let ram = NSView(frame: NSRect(x: (usageX - 50) / 2, y: (view.frame.height - 50) / 2 - 3, width: 50, height: 50))
        let count = NSView(frame: NSRect(x: (usageX + usageSize) + (usageX - 50) / 2, y: (view.frame.height - 50) / 2 - 3, width: 50, height: 50))
        
        self.circle = PieChartView(frame: NSRect(x: 0, y: 0, width: usage.frame.width, height: usage.frame.height), segments: [], drawValue: true)
        self.circle!.toolTip = localizedString("Total Docker CPU usage")
        usage.addSubview(self.circle!)
        
        self.ramCircle = HalfCircleGraphView(frame: NSRect(x: 0, y: 0, width: ram.frame.width, height: ram.frame.height))
        self.ramCircle!.toolTip = localizedString("Total Docker RAM usage")
        self.ramCircle!.color = .systemBlue
        ram.addSubview(self.ramCircle!)
        
        self.countCircle = HalfCircleGraphView(frame: NSRect(x: 0, y: 0, width: count.frame.width, height: count.frame.height))
        self.countCircle!.toolTip = localizedString("Running containers")
        self.countCircle!.color = .systemGreen
        count.addSubview(self.countCircle!)
        
        view.addSubview(ram)
        view.addSubview(usage)
        view.addSubview(count)
        
        return view
    }
    
    private func initChart() -> NSView {
        let view: NSStackView = NSStackView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.chartHeight))
        view.heightAnchor.constraint(equalToConstant: view.bounds.height).isActive = true
        view.orientation = .vertical
        view.spacing = 0
        
        let separator = separatorView(localizedString("Usage history"), origin: NSPoint(x: 0, y: 0), width: self.frame.width)
        
        let lineChartContainer: NSView = {
            let box: NSView = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 70))
            box.heightAnchor.constraint(equalToConstant: box.frame.height).isActive = true
            box.wantsLayer = true
            box.layer?.backgroundColor = NSColor.lightGray.withAlphaComponent(0.1).cgColor
            box.layer?.cornerRadius = 3
            
            let chartFrame = NSRect(x: 1, y: 0, width: box.frame.width, height: box.frame.height)
            self.lineChart = LineChartView(frame: chartFrame, num: self.lineChartHistory)
            self.lineChart?.color = .systemBlue
            box.addSubview(self.lineChart!)
            
            return box
        }()
        
        view.addArrangedSubview(separator)
        view.addArrangedSubview(lineChartContainer)
        
        return view
    }
    
    private func initContainers() -> NSView {
        let view: NSStackView = NSStackView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 0))
        view.orientation = .vertical
        view.spacing = 0
        
        let separator = separatorView(localizedString("Containers"), origin: NSPoint(x: 0, y: 0), width: self.frame.width)
        view.addArrangedSubview(separator)
        
        let scroll = NSScrollView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 200))
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        scroll.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 2
        stack.edgeInsets = NSEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scroll.documentView = stack
        stack.topAnchor.constraint(equalTo: scroll.contentView.topAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: scroll.contentView.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: scroll.contentView.trailingAnchor).isActive = true
        
        self.containersStack = stack
        view.addArrangedSubview(scroll)
        
        return view
    }
    
    public func setup(_ list: Containers_List) {
        let totalCpu = list.compactMap{ $0.cpu }.reduce(0, +)
        let totalRam = list.compactMap{ $0.ram }.reduce(0, +)
        let runningCount = list.filter{ $0.state == "running" }.count
        
        DispatchQueue.main.async {
            self.circle?.setValue(totalCpu / 100)
            self.circle?.setSegments([circle_segment(value: totalCpu / 100, color: .systemBlue)])
            self.circle?.toolTip = "\(localizedString("Total Docker CPU usage")): \(String(format: "%.1f%%", totalCpu))"
            
            // For RAM, we'll assume a 16GB limit for the graph if we don't have a system limit easily accessible, 
            // or just use a sensible default. Better: just show the usage text.
            self.ramCircle?.setValue(0) // Logic for RAM % could be added if host RAM is known
            self.ramCircle?.setText(Units(bytes: totalRam).getReadableMemory())
            
            self.countCircle?.setValue(list.isEmpty ? 0 : Double(runningCount) / Double(list.count))
            self.countCircle?.setText("\(runningCount)")
            
            self.lineChart?.addValue(totalCpu / 100)
            
            self.updateContainersList(list)
            
            if !self.initialized {
                self.recalculateHeight()
                self.initialized = true
            }
        }
    }
    
    private func updateContainersList(_ list: Containers_List) {
        guard let stack = self.containersStack else { return }
        
        // Simple update: clear and rebuild if count changed, otherwise update in place?
        // For simplicity and given usually few containers, clear and rebuild.
        stack.subviews.forEach { $0.removeFromSuperview() }
        
        if list.isEmpty {
            let label = NSTextField(labelWithString: localizedString("No containers running"))
            label.font = NSFont.systemFont(ofSize: 12)
            label.textColor = .secondaryLabelColor
            label.alignment = .center
            stack.addArrangedSubview(label)
            return
        }
        
        for container in list {
            let row = NSStackView()
            row.orientation = .horizontal
            row.spacing = 4
            row.heightAnchor.constraint(equalToConstant: self.containerHeight).isActive = true
            
            let statusDot = NSView(frame: NSRect(x: 0, y: 0, width: 8, height: 8))
            statusDot.wantsLayer = true
            statusDot.layer?.cornerRadius = 4
            statusDot.layer?.backgroundColor = (container.state == "running" ? NSColor.systemGreen : NSColor.systemGray).cgColor
            statusDot.widthAnchor.constraint(equalToConstant: 8).isActive = true
            statusDot.heightAnchor.constraint(equalToConstant: 8).isActive = true
            
            let name = NSTextField(labelWithString: container.names.first?.replacingOccurrences(of: "/", with: "") ?? "Unknown")
            name.font = NSFont.systemFont(ofSize: 11, weight: .medium)
            name.lineBreakMode = .byTruncatingTail
            name.drawsBackground = false
            name.isBezeled = false
            name.isEditable = false
            
            let cpuLabel = NSTextField(labelWithString: container.cpu != nil ? String(format: "%.1f%%", container.cpu!) : "-")
            cpuLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
            cpuLabel.textColor = .secondaryLabelColor
            cpuLabel.alignment = .right
            cpuLabel.widthAnchor.constraint(equalToConstant: 45).isActive = true
            
            let ramLabel = NSTextField(labelWithString: container.ram != nil ? Units(bytes: container.ram!).getReadableMemory() : "-")
            ramLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
            ramLabel.textColor = .secondaryLabelColor
            ramLabel.alignment = .right
            ramLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
            
            row.addArrangedSubview(statusDot)
            row.addArrangedSubview(name)
            row.addArrangedSubview(NSView()) // Spacer
            row.addArrangedSubview(cpuLabel)
            row.addArrangedSubview(ramLabel)
            
            stack.addArrangedSubview(row)
        }
    }
}
