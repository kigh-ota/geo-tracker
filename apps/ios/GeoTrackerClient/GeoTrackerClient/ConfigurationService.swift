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
    
    /// トークンを一部マスクして表示用文字列を取得
    var maskedAuthorizationToken: String {
        guard let token = authorizationToken, !token.isEmpty else {
            return "未設定"
        }
        
        if token.count <= 8 {
            // 短いトークンは全てマスク
            return String(repeating: "*", count: token.count)
        } else {
            // 前4文字と後4文字を残してマスク
            let start = token.prefix(4)
            let end = token.suffix(4)
            let maskLength = token.count - 8
            return "\(start)\(String(repeating: "*", count: maskLength))\(end)"
        }
    }
}