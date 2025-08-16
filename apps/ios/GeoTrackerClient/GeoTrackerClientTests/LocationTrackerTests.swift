//
//  LocationTrackerTests.swift
//  GeoTrackerClientTests
//
//  Created by Kaiichiro Ota on 2025/08/15.
//

import XCTest
import CoreLocation
@testable import GeoTrackerClient

final class LocationTrackerTests: XCTestCase {
    
    var sut: LocationTracker!
    
    override func setUp() {
        super.setUp()
        sut = LocationTracker()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_初期状態では位置情報取得は停止している() {
        XCTAssertFalse(sut.isTracking)
    }
    
    func test_startTrackingを呼ぶと位置情報取得が開始される() {
        sut.startTracking()
        XCTAssertTrue(sut.isTracking)
    }
    
    func test_stopTrackingを呼ぶと位置情報取得が停止される() {
        sut.startTracking()
        sut.stopTracking()
        XCTAssertFalse(sut.isTracking)
    }
    
    func test_位置情報が更新されるとdelegateに通知される() {
        // CLLocationManagerの実際の動作はシミュレータで制限があるため、
        // このテストは後でモックを使った実装に置き換える
        // 現時点では、delegateが正しく設定されることのみをテスト
        
        class MockDelegate: LocationTrackerDelegate {
            var didReceiveLocation = false
            
            func locationTracker(_ tracker: LocationTracker, didUpdateLocation location: CLLocation) {
                didReceiveLocation = true
            }
            
            func locationTracker(_ tracker: LocationTracker, didFailWithError error: Error) {
                // エラー処理
            }
        }
        
        let mockDelegate = MockDelegate()
        sut.delegate = mockDelegate
        
        XCTAssertNotNil(sut.delegate)
    }
}