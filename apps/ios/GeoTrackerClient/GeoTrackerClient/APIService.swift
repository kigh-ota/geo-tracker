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
        print("DEBUG: APIService - Sending request to: \(serverURL)")
        print("DEBUG: APIService - Endpoint: POST /locations/batch")
        print("DEBUG: APIService - Device ID: \(batch.deviceId)")
        print("DEBUG: APIService - Locations count: \(batch.locations.count)")
        
        let input = Operations.PostLocationsBatch.Input(
            headers: .init(),
            body: .json(batch)
        )
        
        let response = try await client.postLocationsBatch(input)
        
        switch response {
        case .created:
            print("DEBUG: APIService - Success: 201 Created")
            return true
        case .badRequest:
            print("DEBUG: APIService - Error: 400 Bad Request")
            return false
        case .unauthorized:
            print("DEBUG: APIService - Error: 401 Unauthorized")
            return false
        case .internalServerError:
            print("DEBUG: APIService - Error: 500 Internal Server Error")
            return false
        case .undocumented(statusCode: let statusCode, _):
            print("DEBUG: APIService - Error: Unexpected status code \(statusCode)")
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