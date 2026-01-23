//
//  widgets.swift
//  Virtualization
//
//  Created by Ibrahim Ishaq KISHIMI
//  Using Swift 6.0
//  Running on macOS 16
//
//  Copyright © 2026 IBRAHIM ISHAQ KISHIMI. All rights reserved.
//

import Kit

// Validating that widget classes are implicitly available via Kit or need subclassing
// In CPU module, it used 'Mini', 'LineChart' etc directly from Kit.
// So we just need to ensure the Module class registers them.
// The config.plist defines which widgets are available.
// In Virtualization.swift, we used Mini directly.

// No specific subclass needed for basic usage unless custom drawing is required.
