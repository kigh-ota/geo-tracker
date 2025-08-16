//
//  ContentView.swift
//  GeoTrackerClient
//
//  Created by Kaiichiro Ota on 2025/08/14.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var isTracking = false
    @State private var statusMessage = "停止中"
    @State private var lastLocation: CLLocation?
    @State private var locationTracker = LocationTracker()
    @State private var locationEventHandler: LocationEventHandler?
    @State private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @State private var logEntries: [LogEntry] = []
    private let maxLogEntries = 50
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Geo Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(statusMessage)
                .font(.title2)
                .foregroundColor(isTracking ? .green : .gray)
            
            VStack(spacing: 20) {
                Button(action: toggleTracking) {
                    Text(isTracking ? "停止" : "開始")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 60)
                        .background(isTracking ? Color.red : Color.blue)
                        .cornerRadius(30)
                }
                
                if authorizationStatus == .authorizedWhenInUse {
                    Button(action: requestBackgroundAuthorization) {
                        Text("バックグラウンド許可を要求")
                            .font(.body)
                            .foregroundColor(.white)
                            .frame(width: 220, height: 50)
                            .background(Color.orange)
                            .cornerRadius(25)
                    }
                }
                
                Text(authorizationStatusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let location = lastLocation {
                VStack(alignment: .leading, spacing: 10) {
                    Text("最新の位置情報:")
                        .font(.headline)
                    Text("緯度: \(String(format: "%.6f", location.coordinate.latitude))")
                    Text("経度: \(String(format: "%.6f", location.coordinate.longitude))")
                    Text("精度: \(String(format: "%.1f", location.horizontalAccuracy))m")
                    Text("取得時刻: \(formatDate(location.timestamp))")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            // 送信履歴ログ
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("送信履歴")
                        .font(.headline)
                    Spacer()
                    if !logEntries.isEmpty {
                        Button("クリア") {
                            logEntries.removeAll()
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                }
                
                if logEntries.isEmpty {
                    Text("履歴なし")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 5) {
                            ForEach(logEntries) { entry in
                                LogEntryView(entry: entry)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .onAppear {
            locationEventHandler = LocationEventHandler(
                onLocationUpdate: { location in
                    lastLocation = location
                    statusMessage = "位置情報取得中"
                    
                    // 位置情報をサーバーに送信
                    Task {
                        do {
                            let deviceId: String
                            if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
                                deviceId = vendorId
                            } else {
                                print("DEBUG: identifierForVendor is nil, using random UUID as fallback")
                                deviceId = UUID().uuidString
                            }
                            let locationDataMapper = LocationDataMapper(deviceId: deviceId)
                            let baseURL = ProcessInfo.processInfo.environment["API_SERVER_URL"] ?? "http://localhost:8000"
                            let serverURL = "\(baseURL)/v1"
                            let apiService = APIService(serverURL: serverURL)
                            
                            let batch = locationDataMapper.createBatch(from: [location])
                            let success = try await apiService.sendLocationBatch(batch)
                            
                            // ログエントリを追加
                            let logEntry = LogEntry(
                                location: location,
                                status: success ? .success : .failure(APIError.invalidResponse)
                            )
                            addLogEntry(logEntry)
                            
                            if success {
                                print("位置情報の送信に成功しました")
                            } else {
                                print("位置情報の送信に失敗しました")
                            }
                        } catch {
                            print("API送信エラー: \(error)")
                            // エラーログを追加
                            let logEntry = LogEntry(
                                location: location,
                                status: .failure(error)
                            )
                            addLogEntry(logEntry)
                        }
                    }
                },
                onError: { error in
                    statusMessage = "エラー: \(error.localizedDescription)"
                },
                onAuthorizationStatusUpdate: { status in
                    authorizationStatus = status
                }
            )
            locationTracker.delegate = locationEventHandler
        }
    }
    
    private func toggleTracking() {
        if isTracking {
            locationTracker.stopTracking()
            statusMessage = "停止中"
        } else {
            locationTracker.startTracking()
            statusMessage = "位置情報取得中"
        }
        isTracking.toggle()
    }
    
    private func requestBackgroundAuthorization() {
        locationTracker.enableBackgroundLocationUpdates()
        locationTracker.requestBackgroundLocationAuthorization()
    }
    
    private var authorizationStatusText: String {
        switch authorizationStatus {
        case .notDetermined:
            return "位置情報許可: 未決定"
        case .denied:
            return "位置情報許可: 拒否"
        case .restricted:
            return "位置情報許可: 制限"
        case .authorizedWhenInUse:
            return "位置情報許可: アプリ使用中のみ"
        case .authorizedAlways:
            return "位置情報許可: 常時許可（バックグラウンド対応）"
        @unknown default:
            return "位置情報許可: 不明"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    private func addLogEntry(_ entry: LogEntry) {
        logEntries.insert(entry, at: 0) // 新しいものを先頭に
        
        // 最大件数を超えたら古いものを削除
        if logEntries.count > maxLogEntries {
            logEntries.removeLast()
        }
    }
}

class LocationEventHandler: LocationTrackerDelegate {
    let onLocationUpdate: (CLLocation) -> Void
    let onError: (Error) -> Void
    let onAuthorizationStatusUpdate: (CLAuthorizationStatus) -> Void
    
    init(onLocationUpdate: @escaping (CLLocation) -> Void, 
         onError: @escaping (Error) -> Void,
         onAuthorizationStatusUpdate: @escaping (CLAuthorizationStatus) -> Void) {
        self.onLocationUpdate = onLocationUpdate
        self.onError = onError
        self.onAuthorizationStatusUpdate = onAuthorizationStatusUpdate
    }
    
    func locationTracker(_ tracker: LocationTracker, didUpdateLocation location: CLLocation) {
        onLocationUpdate(location)
    }
    
    func locationTracker(_ tracker: LocationTracker, didFailWithError error: Error) {
        onError(error)
    }
    
    func locationTracker(_ tracker: LocationTracker, didUpdateAuthorizationStatus status: CLAuthorizationStatus) {
        onAuthorizationStatusUpdate(status)
    }
}

struct LogEntryView: View {
    let entry: LogEntry
    
    var body: some View {
        HStack(spacing: 8) {
            // ステータスアイコン
            Image(systemName: entry.status.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(entry.status.isSuccess ? .green : .red)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(formatTime(entry.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(entry.status.displayMessage)
                        .font(.caption)
                        .foregroundColor(entry.status.isSuccess ? .green : .red)
                }
                
                Text("(\(String(format: "%.4f", entry.location.coordinate.latitude)), \(String(format: "%.4f", entry.location.coordinate.longitude)))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
