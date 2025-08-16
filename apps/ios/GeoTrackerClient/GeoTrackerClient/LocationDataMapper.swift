//
//  LocationDataMapper.swift
//  GeoTrackerClient
//
//  Created by Kaiichiro Ota on 2025/08/15.
//

import Foundation
import CoreLocation
import OpenAPIRuntime

class LocationDataMapper {
    let deviceId: String
    var deviceInfo: Components.Schemas.DeviceInfo?
    var currentActivityType: Components.Schemas.Location.ActivityTypePayload = .unknown
    var batteryLevel: Double?
    
    init(deviceId: String) {
        self.deviceId = deviceId
    }
    
    func createBatch(from locations: [CLLocation]) -> Components.Schemas.LocationBatch {
        let mappedLocations = locations.map { clLocation in
            Components.Schemas.Location(
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
        
        return Components.Schemas.LocationBatch(
            deviceId: deviceId,
            deviceInfo: deviceInfo,
            locations: mappedLocations
        )
    }
}