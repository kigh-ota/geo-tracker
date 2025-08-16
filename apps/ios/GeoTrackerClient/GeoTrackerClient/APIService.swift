//
//  APIService.swift
//  GeoTrackerClient
//
//  Created by Kaiichiro Ota on 2025/08/16.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

class APIService {
    let serverURL: String
    private let client: Client
    
    init(serverURL: String, transport: (any ClientTransport)? = nil) {
        self.serverURL = serverURL
        
        // OpenAPIクライアントを初期化
        guard let url = URL(string: serverURL) else {
            fatalError("Invalid server URL: \(serverURL)")
        }
        
        self.client = Client(
            serverURL: url,
            transport: transport ?? URLSessionTransport()
        )
    }
    
    /// 位置情報バッチをサーバーに送信
    func sendLocationBatch(_ batch: Components.Schemas.LocationBatch) async throws -> Bool {
        let input = Operations.PostLocationsBatch.Input(
            headers: .init(),
            body: .json(batch)
        )
        
        let response = try await client.postLocationsBatch(input)
        
        switch response {
        case .created:
            return true
        case .badRequest, .unauthorized, .internalServerError:
            return false
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unexpectedStatusCode(statusCode)
        }
    }
    
    /// ヘルスチェック
    func checkHealth() async throws -> Bool {
        let input = Operations.GetHealth.Input()
        let response = try await client.getHealth(input)
        
        switch response {
        case .ok:
            return true
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unexpectedStatusCode(statusCode)
        }
    }
    
}

enum APIError: Error {
    case unexpectedStatusCode(Int)
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .unexpectedStatusCode(let code):
            return "Unexpected status code: \(code)"
        case .invalidResponse:
            return "Invalid response format"
        }
    }
}