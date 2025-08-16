//
//  LocationDataMapperTests.swift
//  GeoTrackerClientTests
//
//  Created by Kaiichiro Ota on 2025/08/15.
//

import XCTest
import CoreLocation
@testable import GeoTrackerClient

final class LocationDataMapperTests: XCTestCase {
    
    var sut: LocationDataMapper!
    let testDeviceId = "550e8400-e29b-41d4-a716-446655440000"
    
    override func setUp() {
        super.setUp()
        sut = LocationDataMapper(deviceId: testDeviceId)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_単一の位置情報をLocationBatchに変換できる() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
        let location = CLLocation(
            coordinate: coordinate,
            altitude: 45.2,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 3.0,
            course: 180.0,
            speed: 1.5,
            timestamp: Date()
        )
        
        // When
        let batch = sut.createBatch(from: [location])
        
        // Then
        XCTAssertEqual(batch.deviceId, testDeviceId)
        XCTAssertEqual(batch.locations.count, 1)
        
        let mappedLocation = batch.locations.first!
        XCTAssertEqual(mappedLocation.latitude, 35.6812)
        XCTAssertEqual(mappedLocation.longitude, 139.7671)
        XCTAssertEqual(mappedLocation.altitude, 45.2)
        XCTAssertEqual(mappedLocation.accuracy, 5.0)
        XCTAssertEqual(mappedLocation.heading, 180.0)
        XCTAssertEqual(mappedLocation.speed, 1.5)
    }
    
    func test_複数の位置情報をLocationBatchに変換できる() {
        // Given
        let locations = [
            CLLocation(latitude: 35.6812, longitude: 139.7671),
            CLLocation(latitude: 35.6813, longitude: 139.7672),
            CLLocation(latitude: 35.6814, longitude: 139.7673)
        ]
        
        // When
        let batch = sut.createBatch(from: locations)
        
        // Then
        XCTAssertEqual(batch.locations.count, 3)
        XCTAssertEqual(batch.locations[0].latitude, 35.6812)
        XCTAssertEqual(batch.locations[1].latitude, 35.6813)
        XCTAssertEqual(batch.locations[2].latitude, 35.6814)
    }
    
    func test_デバイス情報を含むLocationBatchを作成できる() {
        // Given
        let location = CLLocation(latitude: 35.6812, longitude: 139.7671)
        let deviceInfo = Components.Schemas.DeviceInfo(
            model: "iPhone14,2",
            osVersion: "iOS 17.0"
        )
        sut.deviceInfo = deviceInfo
        
        // When
        let batch = sut.createBatch(from: [location])
        
        // Then
        XCTAssertNotNil(batch.deviceInfo)
        XCTAssertEqual(batch.deviceInfo?.model, "iPhone14,2")
        XCTAssertEqual(batch.deviceInfo?.osVersion, "iOS 17.0")
    }
    
    func test_アクティビティタイプを設定できる() {
        // Given
        let location = CLLocation(latitude: 35.6812, longitude: 139.7671)
        sut.currentActivityType = .walking
        
        // When
        let batch = sut.createBatch(from: [location])
        
        // Then
        XCTAssertEqual(batch.locations.first?.activityType, .walking)
    }
    
    func test_バッテリーレベルを設定できる() {
        // Given
        let location = CLLocation(latitude: 35.6812, longitude: 139.7671)
        sut.batteryLevel = 0.85
        
        // When
        let batch = sut.createBatch(from: [location])
        
        // Then
        XCTAssertEqual(batch.locations.first?.batteryLevel, 0.85)
    }
}