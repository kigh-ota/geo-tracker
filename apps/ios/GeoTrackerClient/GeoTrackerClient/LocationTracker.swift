//
//  LocationTracker.swift
//  GeoTrackerClient
//
//  Created by Kaiichiro Ota on 2025/08/15.
//

import Foundation
import CoreLocation

class LocationTracker: NSObject {
    private let locationManager = CLLocationManager()
    private(set) var isTracking = false
    weak var delegate: LocationTrackerDelegate?
    
    var isBackgroundLocationUpdatesEnabled: Bool {
        return locationManager.allowsBackgroundLocationUpdates
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = 10 // 10メートル移動するごとに更新
    }
    
    func enableBackgroundLocationUpdates() {
        // Background Modesが設定されている場合のみ有効化
        guard Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String] != nil else {
            print("Background Modes not configured")
            return
        }
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func startTracking() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        isTracking = true
    }
    
    func requestBackgroundLocationAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTracking = false
    }
}

extension LocationTracker: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.locationTracker(self, didUpdateLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
        if let clError = error as? CLError {
            print("CLError code: \(clError.code.rawValue)")
            switch clError.code {
            case .locationUnknown:
                print("Location service was unable to determine the location")
            case .denied:
                print("Location services are disabled or denied")
            case .network:
                print("Network was unavailable or network error occurred")
            default:
                print("Other location error: \(clError.localizedDescription)")
            }
        }
        delegate?.locationTracker(self, didFailWithError: error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            // バックグラウンド位置取得が許可された場合
            if isTracking {
                locationManager.startUpdatingLocation()
            }
            delegate?.locationTracker(self, didUpdateAuthorizationStatus: .authorizedAlways)
        case .authorizedWhenInUse:
            // フォアグラウンドのみの許可
            if isTracking {
                locationManager.startUpdatingLocation()
            }
            delegate?.locationTracker(self, didUpdateAuthorizationStatus: .authorizedWhenInUse)
        case .denied, .restricted:
            delegate?.locationTracker(self, didFailWithError: LocationError.authorizationDenied)
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

enum LocationError: LocalizedError {
    case authorizationDenied
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "位置情報の使用が許可されていません"
        }
    }
}

protocol LocationTrackerDelegate: AnyObject {
    func locationTracker(_ tracker: LocationTracker, didUpdateLocation location: CLLocation)
    func locationTracker(_ tracker: LocationTracker, didFailWithError error: Error)
    func locationTracker(_ tracker: LocationTracker, didUpdateAuthorizationStatus status: CLAuthorizationStatus)
}