//
//  readers.swift
//  Virtualization
//
//  Created by Ibrahim Ishaq KISHIMI
//  Using Swift 6.0
//  Running on macOS 16
//
//  Copyright © 2026 IBRAHIM ISHAQ KISHIMI. All rights reserved.
//

import Foundation
import Kit

public struct Port: Codable {
    public let privatePort: Int
    public let publicPort: Int?
    public let type: String
    
    enum CodingKeys: String, CodingKey {
        case privatePort = "PrivatePort"
        case publicPort = "PublicPort"
        case type = "Type"
    }
}

public struct Container: Codable {
    public let id: String
    public let names: [String]
    public let image: String
    public let state: String
    public let status: String
    public let ports: [Port]
    
    public var cpu: Double? = nil
    public var ram: Int64? = nil
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case names = "Names"
        case image = "Image"
        case state = "State"
        case status = "Status"
        case ports = "Ports"
    }
}

public typealias Containers_List = [Container]

struct MemoryStats: Codable {
    let usage: Int64?
    let limit: Int64?
}

struct CPUUsage: Codable {
    let totalUsage: Int64?
    
    enum CodingKeys: String, CodingKey {
        case totalUsage = "total_usage"
    }
}

struct CPUStats: Codable {
    let cpuUsage: CPUUsage?
    let systemCpuUsage: Int64?
    let onlineCpus: Int?
    
    enum CodingKeys: String, CodingKey {
        case cpuUsage = "cpu_usage"
        case systemCpuUsage = "system_cpu_usage"
        case onlineCpus = "online_cpus"
    }
}

struct DockerStats: Codable {
    let memoryStats: MemoryStats?
    let cpuStats: CPUStats?
    let preCpuStats: CPUStats?
    
    enum CodingKeys: String, CodingKey {
        case memoryStats = "memory_stats"
        case cpuStats = "cpu_stats"
        case preCpuStats = "precpu_stats"
    }
}

public class DockerReader: Reader<Containers_List> {
    private var socketPath: String = "/var/run/docker.sock"
    
    public override func setup() {
        self.socketPath = Store.shared.string(key: "DockerReader_socketPath", defaultValue: self.socketPath)
    }
    
    public func setSocketPath(_ path: String) {
        self.socketPath = path
    }
    
    public override func read() {
        let task = Process()
        task.launchPath = "/usr/bin/curl"
        task.arguments = ["--unix-socket", self.socketPath, "http://localhost/containers/json?all=true"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if var containers = try? JSONDecoder().decode([Container].self, from: data) {
                let onlyRunning = Store.shared.bool(key: "Virtualization_onlyRunning", defaultValue: false)
                if onlyRunning {
                    containers = containers.filter { $0.state == "running" }
                }
                
                for i in 0..<containers.count where containers[i].state == "running" {
                    if let stats = self.fetchStats(id: containers[i].id) {
                        if let usage = stats.memoryStats?.usage {
                            containers[i].ram = usage
                        }
                        
                        if let cpuUsage = stats.cpuStats?.cpuUsage?.totalUsage,
                           let preCpuUsage = stats.preCpuStats?.cpuUsage?.totalUsage,
                           let systemUsage = stats.cpuStats?.systemCpuUsage,
                           let preSystemUsage = stats.preCpuStats?.systemCpuUsage {
                            
                            let cpuDelta = Double(cpuUsage - preCpuUsage)
                            let systemDelta = Double(systemUsage - preSystemUsage)
                            let onlineCpus = Double(stats.cpuStats?.onlineCpus ?? 1)
                            
                            if systemDelta > 0 && cpuDelta > 0 {
                                containers[i].cpu = (cpuDelta / systemDelta) * onlineCpus * 100.0
                            }
                        }
                    }
                }
                
                self.callback(containers)
            }
        } catch {
            self.callback([])
        }
    }
    
    private func fetchStats(id: String) -> DockerStats? {
        let task = Process()
        task.launchPath = "/usr/bin/curl"
        task.arguments = ["--unix-socket", self.socketPath, "http://localhost/containers/\(id)/stats?stream=false"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return try? JSONDecoder().decode(DockerStats.self, from: data)
        } catch {
            return nil
        }
    }
}
