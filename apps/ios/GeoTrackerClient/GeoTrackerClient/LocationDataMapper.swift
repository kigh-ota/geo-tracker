//
//  LocationDataMapper.swift
//  GeoTrackerClient
//
//  Created by Kaiichiro Ota on 2025/08/15.
//

import Foundation
import CoreLocation

class LocationDataMapper {
    let deviceId: String
    var deviceInfo: DeviceInfo?
    var currentActivityType: ActivityType = .unknown
    var batteryLevel: Double?
    
    struct DeviceInfo {
        let model: String
        let osVersion: String
    }
    
    enum ActivityType {
        case unknown
        case stationary
        case walking
        case running
        case automotive
        case cycling
    }
    
    // 一時的なLocationBatch構造体（後でOpenAPI生成型に置き換え）
    struct LocationBatch {
        let deviceId: String
        let deviceInfo: DeviceInfo?
        let locations: [Location]
    }
    
    struct Location {
        let latitude: Double
        let longitude: Double
        let accuracy: Float?
        let timestamp: Date
        let altitude: Double?
        let speed: Float?
        let heading: Float?
        let batteryLevel: Float?
        let activityType: ActivityType?
    }
    
    init(deviceId: String) {
        self.deviceId = deviceId
    }
    
    func createBatch(from locations: [CLLocation]) -> LocationBatch {
        let mappedLocations = locations.map { clLocation in
            Location(
                latitude: clLocation.coordinate.latitude,
                longitude: clLocation.coordinate.longitude,
                accuracy: clLocation.horizontalAccuracy > 0 ? Float(clLocation.horizontalAccuracy) : nil,
                timestamp: clLocation.timestamp,
                altitude: clLocation.altitude,
                speed: clLocation.speed >= 0 ? Float(clLocation.speed) : nil,
                heading: clLocation.course >= 0 ? Float(clLocation.course) : nil,
                batteryLevel: batteryLevel.map { Float($0) },
                activityType: currentActivityType
            )
        }
        
        return LocationBatch(
            deviceId: deviceId,
            deviceInfo: deviceInfo,
            locations: mappedLocations
        )
    }
}