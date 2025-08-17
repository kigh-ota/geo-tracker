//
//  ConfigurationServiceTests.swift
//  GeoTrackerClientTests
//
//  Created by Kaiichiro Ota on 2025/08/17.
//

import XCTest
@testable import GeoTrackerClient

final class ConfigurationServiceTests: XCTestCase {
    
    func test_デフォルト設定値が正しく取得できる() {
        // Given
        let mockEnvironment: [String: String] = [:]
        let sut = ConfigurationService(environment: mockEnvironment)
        
        // When & Then
        XCTAssertEqual(sut.serverURL, "http://localhost:8000/v1")
        XCTAssertNil(sut.authorizationToken)
    }
    
    func test_環境変数からサーバーURLを取得できる() {
        // Given
        let mockEnvironment = ["API_SERVER_URL": "https://api.example.com"]
        let sut = ConfigurationService(environment: mockEnvironment)
        
        // When & Then
        XCTAssertEqual(sut.serverURL, "https://api.example.com/v1")
    }
    
    func test_環境変数からAuthorizationトークンを取得できる() {
        // Given
        let mockEnvironment = ["API_AUTHORIZATION_TOKEN": "test-token-123"]
        let sut = ConfigurationService(environment: mockEnvironment)
        
        // When & Then
        XCTAssertEqual(sut.authorizationToken, "test-token-123")
    }
    
    func test_両方の環境変数が設定されている場合() {
        // Given
        let mockEnvironment = [
            "API_SERVER_URL": "https://api.example.com",
            "API_AUTHORIZATION_TOKEN": "test-token-123"
        ]
        let sut = ConfigurationService(environment: mockEnvironment)
        
        // When & Then
        XCTAssertEqual(sut.serverURL, "https://api.example.com/v1")
        XCTAssertEqual(sut.authorizationToken, "test-token-123")
    }
    
    func test_サーバーURLにv1が自動的に追加される() {
        // Given
        let mockEnvironment = ["API_SERVER_URL": "https://api.example.com/"]
        let sut = ConfigurationService(environment: mockEnvironment)
        
        // When & Then
        XCTAssertEqual(sut.serverURL, "https://api.example.com/v1")
    }
}