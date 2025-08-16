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
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Geo Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(statusMessage)
                .font(.title2)
                .foregroundColor(isTracking ? .green : .gray)
            
            Button(action: toggleTracking) {
                Text(isTracking ? "停止" : "開始")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 60)
                    .background(isTracking ? Color.red : Color.blue)
                    .cornerRadius(30)
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
            
            Spacer()
        }
        .padding()
        .onAppear {
            locationEventHandler = LocationEventHandler(
                onLocationUpdate: { location in
                    lastLocation = location
                    statusMessage = "位置情報取得中"
                },
                onError: { error in
                    statusMessage = "エラー: \(error.localizedDescription)"
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

class LocationEventHandler: LocationTrackerDelegate {
    let onLocationUpdate: (CLLocation) -> Void
    let onError: (Error) -> Void
    
    init(onLocationUpdate: @escaping (CLLocation) -> Void, onError: @escaping (Error) -> Void) {
        self.onLocationUpdate = onLocationUpdate
        self.onError = onError
    }
    
    func locationTracker(_ tracker: LocationTracker, didUpdateLocation location: CLLocation) {
        onLocationUpdate(location)
    }
    
    func locationTracker(_ tracker: LocationTracker, didFailWithError error: Error) {
        onError(error)
    }
}

#Preview {
    ContentView()
}
