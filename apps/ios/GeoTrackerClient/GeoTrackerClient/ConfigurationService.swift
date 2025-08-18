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
        self.serverURL = environment["API_SERVER_URL"] ?? "http://localhost:8000/v1"
        
        // Authorizationトークンの設定
        self.authorizationToken = environment["API_AUTHORIZATION_TOKEN"]
    }
}