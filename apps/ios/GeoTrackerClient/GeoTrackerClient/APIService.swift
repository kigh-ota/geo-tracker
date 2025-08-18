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
    private let configuration: ConfigurationService?
    
    init(serverURL: String, transport: (any ClientTransport)? = nil) {
        self.serverURL = serverURL
        self.configuration = nil
        
        // OpenAPIクライアントを初期化
        guard let url = URL(string: serverURL) else {
            fatalError("Invalid server URL: \(serverURL)")
        }
        
        self.client = Client(
            serverURL: url,
            transport: transport ?? URLSessionTransport()
        )
    }
    
    init(configuration: ConfigurationService, transport: (any ClientTransport)? = nil) {
        self.serverURL = configuration.serverURL
        self.configuration = configuration
        
        // OpenAPIクライアントを初期化
        guard let url = URL(string: configuration.serverURL) else {
            fatalError("Invalid server URL: \(configuration.serverURL)")
        }
        
        let finalTransport: any ClientTransport
        if let customTransport = transport {
            finalTransport = customTransport
        } else {
            // Authorizationヘッダーを自動的に追加するカスタムトランスポート
            finalTransport = AuthorizationHeaderTransport(
                baseTransport: URLSessionTransport(),
                authorizationToken: configuration.authorizationToken
            )
        }
        
        self.client = Client(
            serverURL: url,
            transport: finalTransport
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

/// Authorizationヘッダーを自動的に追加するカスタムトランスポート
struct AuthorizationHeaderTransport: ClientTransport {
    private let baseTransport: any ClientTransport
    private let authorizationToken: String?
    
    init(baseTransport: any ClientTransport, authorizationToken: String?) {
        self.baseTransport = baseTransport
        self.authorizationToken = authorizationToken
    }
    
    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var modifiedRequest = request
        
        // Authorizationヘッダーを追加
        if let token = authorizationToken {
            modifiedRequest.headerFields[.authorization] = "Bearer \(token)"
        }
        
        return try await baseTransport.send(
            modifiedRequest,
            body: body,
            baseURL: baseURL,
            operationID: operationID
        )
    }
}