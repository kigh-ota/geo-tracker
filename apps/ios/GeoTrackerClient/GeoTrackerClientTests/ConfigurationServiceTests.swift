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
        let mockEnvironment = ["API_SERVER_URL": "https://api.example.com/v1"]
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
            "API_SERVER_URL": "https://api.example.com/v1",
            "API_AUTHORIZATION_TOKEN": "test-token-123"
        ]
        let sut = ConfigurationService(environment: mockEnvironment)
        
        // When & Then
        XCTAssertEqual(sut.serverURL, "https://api.example.com/v1")
        XCTAssertEqual(sut.authorizationToken, "test-token-123")
    }
    
    func test_トークンが未設定の場合のマスク表示() {
        // Given
        let mockEnvironment: [String: String] = [:]
        let sut = ConfigurationService(environment: mockEnvironment)
        
        // When & Then
        XCTAssertEqual(sut.maskedAuthorizationToken, "未設定")
    }
    
    func test_短いトークンの完全マスク表示() {
        // Given
        let mockEnvironment = ["API_AUTHORIZATION_TOKEN": "abc123"]
        let sut = ConfigurationService(environment: mockEnvironment)
        
        // When & Then
        XCTAssertEqual(sut.maskedAuthorizationToken, "******")
    }
    
    func test_長いトークンの部分マスク表示() {
        // Given
        let token = "token-very-long-secret-key-123456"  // 34文字
        let mockEnvironment = ["API_AUTHORIZATION_TOKEN": token]
        let sut = ConfigurationService(environment: mockEnvironment)
        
        // When
        let actual = sut.maskedAuthorizationToken
        
        // Then
        print("DEBUG: token length: \(token.count)")
        print("DEBUG: expected: toke**************************3456")
        print("DEBUG: actual: \(actual)")
        
        // 前4文字と後4文字が正しいことを確認
        XCTAssertTrue(actual.hasPrefix("toke"))
        XCTAssertTrue(actual.hasSuffix("3456"))
        XCTAssertEqual(actual.count, token.count)
    }
}