//
//  MetricLogger.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import Foundation
import os

@MainActor
final class MetricLogger {

    static let shared = MetricLogger()

    private let logger = Logger(subsystem: "com.tamakou.Saber", category: "Performance")
    private let fileHandle: FileHandle?
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private init() {
        let url = MetricLogger.makeLogURL()
        fileHandle = try? MetricLogger.prepareHandle(url: url)
    }

    func recordFrame(deltaTime: TimeInterval, inputLatency: TimeInterval, phase: CombatPhase) {
        logger.log("frame_dt=\(deltaTime, format: .fixed(precision: 4)) latency=\(inputLatency, format: .fixed(precision: 4)) phase=\(String(describing: phase))")

        guard let fileHandle else { return }
        let timestamp = dateFormatter.string(from: Date())
        let line = "\(timestamp),dt=\(deltaTime),latency=\(inputLatency),phase=\(phase)\n"
        if let data = line.data(using: .utf8) {
            do {
                try fileHandle.seekToEnd()
                try fileHandle.write(contentsOf: data)
            } catch {
                logger.error("metric write failed: \(error.localizedDescription)")
            }
        }
    }

    private static func makeLogURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let folder = base.appendingPathComponent("SaberMetrics", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder.appendingPathComponent("frame_metrics.log")
    }

    private static func prepareHandle(url: URL) throws -> FileHandle {
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
        let handle = try FileHandle(forUpdating: url)
        try handle.seekToEnd()
        return handle
    }
}
