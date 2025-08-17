//
//  ConfigurationService.swift
//  GeoTrackerClient
//
//  Created by Kaiichiro Ota on 2025/08/17.
//

import Foundation

class ConfigurationService {
    let serverURL: String
    let authorizationToken: String?
    
    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        // サーバーURLの設定
        let baseURL = environment["API_SERVER_URL"] ?? "http://localhost:8000"
        // v1エンドポイントを自動的に追加（すでに/で終わっている場合は考慮）
        if baseURL.hasSuffix("/") {
            self.serverURL = baseURL + "v1"
        } else {
            self.serverURL = baseURL + "/v1"
        }
        
        // Authorizationトークンの設定
        self.authorizationToken = environment["API_AUTHORIZATION_TOKEN"]
    }
}