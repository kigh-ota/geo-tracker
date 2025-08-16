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
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // バックグラウンド位置情報は一時的に無効化（権限設定のため）
        // locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = 10 // 10メートル移動するごとに更新
    }
    
    func startTracking() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        isTracking = true
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
        case .authorizedAlways, .authorizedWhenInUse:
            if isTracking {
                locationManager.startUpdatingLocation()
            }
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
}