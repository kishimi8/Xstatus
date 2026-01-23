//
//  portal.swift
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

internal class VirtualizationPortal: PortalWrapper {
    public override func load() {
        self.subviews.forEach{ $0.removeFromSuperview() }
        super.load()
        
        // Add custom content if needed
    }
}
