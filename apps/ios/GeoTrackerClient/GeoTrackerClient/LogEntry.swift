//
//  LogEntry.swift
//  GeoTrackerClient
//
//  Created by Kaiichiro Ota on 2025/08/16.
//

import Foundation
import CoreLocation

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let location: CLLocation
    let status: LogStatus
    let message: String
    
    init(location: CLLocation, status: LogStatus, message: String = "") {
        self.timestamp = Date()
        self.location = location
        self.status = status
        self.message = message
    }
}

enum LogStatus {
    case success
    case failure(Error)
    
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var displayMessage: String {
        switch self {
        case .success:
            return "送信成功"
        case .failure(let error):
            return "送信失敗: \(error.localizedDescription)"
        }
    }
}