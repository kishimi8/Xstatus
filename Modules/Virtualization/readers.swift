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
    private var history: [String: (cpu: [Double], ram: [Double])] = [:]
    private let maxHistory: Int = 180
    
    public override func setup() {
        self.socketPath = Store.shared.string(key: "DockerReader_socketPath", defaultValue: self.socketPath)
    }
    
    public func setSocketPath(_ path: String) {
        self.socketPath = path
    }
    
    public override func read() {
        guard let data = self.fetchData(path: "/containers/json?all=true") else {
            self.callback([])
            return
        }
        
        do {
            var containers = try JSONDecoder().decode([Container].self, from: data)
            let onlyRunning = Store.shared.bool(key: "Virtualization_onlyRunning", defaultValue: false)
            if onlyRunning {
                containers = containers.filter { $0.state == "running" }
            }
            
            for i in 0..<containers.count where containers[i].state == "running" {
                if let statsData = self.fetchData(path: "/containers/\(containers[i].id)/stats?stream=false") {
                    do {
                        let stats = try JSONDecoder().decode(DockerStats.self, from: statsData)
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
                    } catch let err {
                        debug("failed to decode stats for \(containers[i].id): \(err)", log: self.log)
                    }
                }
                
                // Track history
                let id = containers[i].id
                if self.history[id] == nil {
                    self.history[id] = (cpu: [], ram: [])
                }
                
                self.history[id]!.cpu.append(containers[i].cpu ?? 0)
                self.history[id]!.ram.append(Double(containers[i].ram ?? 0))
                
                if self.history[id]!.cpu.count > self.maxHistory {
                    self.history[id]!.cpu.removeFirst()
                }
                if self.history[id]!.ram.count > self.maxHistory {
                    self.history[id]!.ram.removeFirst()
                }
                
                containers[i].cpuHistory = self.history[id]!.cpu
                containers[i].ramHistory = self.history[id]!.ram
            }
            
            // Clean up history for removed containers
            let currentIds = Set(containers.map { $0.id })
            self.history = self.history.filter { currentIds.contains($0.key) }
            
            self.callback(containers)
        } catch let err {
            error("failed to decode containers list: \(err)", log: self.log)
            self.callback([])
        }
    }
    
    private func fetchData(path: String) -> Data? {
        let (args, url) = self.getRequestParams(path)
        debug("fetching docker data via curl: \(url) (socket: \(self.socketPath))", log: self.log)
        
        let task = Process()
        task.launchPath = "/usr/bin/curl"
        task.arguments = ["-s"] + args + [url]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if data.isEmpty {
                debug("curl returned empty data", log: self.log)
            }
            return data
        } catch let err {
            error("curl execution failed: \(err)", log: self.log)
            return nil
        }
    }
    
    private func getRequestParams(_ path: String) -> (args: [String], url: String) {
        if self.socketPath.hasPrefix("/") {
            return (["--unix-socket", self.socketPath], "http://localhost\(path)")
        }
        return ([], "http://\(self.socketPath)\(path)")
    }
}
