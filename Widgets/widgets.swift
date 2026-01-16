//
//  widgets.swift
//  WidgetsExtension
//
//  Created by Ibrahim Ishaq KISHIMI
//  Using Swift 6.0
//  Running on macOS 16
//
//  Copyright © 2026 IBRAHIM ISHAQ KISHIMI. All rights reserved.
//

import SwiftUI

import CPU
import GPU
import RAM
import Disk
import Net

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        CPUWidget()
        GPUWidget()
        RAMWidget()
        DiskWidget()
        NetworkWidget()
        UnitedWidget()
    }
}
