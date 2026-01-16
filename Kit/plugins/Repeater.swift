//
//  Repeater.swift
//  Kit
//
//  Created by Ibrahim Ishaq KISHIMI
//  Using Swift 6.0
//  Running on macOS 16
//
//  Copyright © 2026 IBRAHIM ISHAQ KISHIMI. All rights reserved.
//

import Foundation

private enum RepeaterState {
    case paused
    case running
}

internal class Repeater {
    private var callback: (() -> Void)
    private var state: RepeaterState = .paused
    
    private var timer: DispatchSourceTimer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "eu.exelban.Stats.Repeater", qos: .default))
    
    internal init(seconds: Int, callback: @escaping (() -> Void)) {
        self.callback = callback
        self.setupTimer(seconds)
    }
    
    deinit {
        self.timer.cancel()
        self.start()
    }
    
    private func setupTimer(_ interval: Int) {
        self.timer.schedule(
            deadline: DispatchTime.now() + Double(interval),
            repeating: .seconds(interval),
            leeway: .seconds(0)
        )
        self.timer.setEventHandler { [weak self] in
            self?.callback()
        }
    }
    
    internal func start() {
        guard self.state == .paused else { return }
        
        self.timer.resume()
        self.state = .running
    }
    
    internal func pause() {
        guard self.state == .running else { return }
        
        self.timer.suspend()
        self.state = .paused
    }
    
    internal func reset(seconds: Int, restart: Bool = false) {
        if self.state == .running {
            self.pause()
        }
        
        self.setupTimer(seconds)
        
        if restart {
            self.callback()
            self.start()
        }
    }
}
