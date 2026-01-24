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
        VirtualizationWidget()
        UnitedWidget()
    }
}

import WidgetKit
import Kit

public struct Virtualization_entry: TimelineEntry {
    public static let kind = "VirtualizationWidget"
    public static var snapshot: Virtualization_entry = Virtualization_entry(value: [])
    
    public var date: Date {
        Calendar.current.date(byAdding: .second, value: 5, to: Date())!
    }
    public var value: Containers_List? = nil
}

@available(macOS 11.0, *)
public struct VirtualizationProvider: TimelineProvider {
    public typealias Entry = Virtualization_entry
    
    private let userDefaults: UserDefaults? = UserDefaults(suiteName: "\(Bundle.main.object(forInfoDictionaryKey: "TeamId") as! String).ng.kishimi8.XStatus.widgets")
    
    public func placeholder(in context: Context) -> Virtualization_entry {
        Virtualization_entry()
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (Virtualization_entry) -> Void) {
        completion(Virtualization_entry.snapshot)
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<Virtualization_entry>) -> Void) {
        self.userDefaults?.set(Date().timeIntervalSince1970, forKey: Virtualization_entry.kind)
        var entry = Virtualization_entry()
        if let raw = self.userDefaults?.data(forKey: "Virtualization@DockerReader"), 
           let containers = try? JSONDecoder().decode(Containers_List.self, from: raw) {
            entry.value = containers
        }
        let entries: [Virtualization_entry] = [entry]
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

@available(macOS 14.0, *)
public struct VirtualizationWidget: Widget {
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: Virtualization_entry.kind, provider: VirtualizationProvider()) { entry in
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "server.rack")
                    Text("Docker")
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    if let value = entry.value {
                        Text("\(value.count)")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                
                if let containers = entry.value, !containers.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(containers.prefix(3), id: \.id) { container in
                            HStack {
                                Circle()
                                    .fill(container.state == "running" ? Color.green : Color.gray)
                                    .frame(width: 8, height: 8)
                                Text(container.names.first?.replacingOccurrences(of: "/", with: "") ?? "Unknown")
                                    .font(.system(size: 11))
                                    .lineLimit(1)
                                Spacer()
                                if let cpu = container.cpu {
                                    Text(String(format: "%.1f%%", cpu))
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                } else {
                    Spacer()
                    Text("No containers")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
            }
            .padding()
            .containerBackground(for: .widget) {
                Color.clear
            }
        }
        .configurationDisplayName("Virtualization widget")
        .description("Displays Docker containers stats")
        .supportedFamilies([.systemSmall])
    }
}
