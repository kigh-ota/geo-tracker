//
//  MockURLProtocol.swift
//  GeoTrackerClientTests
//
//  Created by Kaiichiro Ota on 2025/08/16.
//

import Foundation

/// URLSessionをモックするためのカスタムURLProtocol
class MockURLProtocol: URLProtocol {
    /// リクエストハンドラー
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    /// 最後に受信したリクエスト
    static var lastRequest: URLRequest?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // リクエストを記録
        MockURLProtocol.lastRequest = request
        
        guard let handler = MockURLProtocol.requestHandler else {
            let error = NSError(domain: "MockURLProtocol", code: -1, userInfo: [NSLocalizedDescriptionKey: "No request handler set"])
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        // 必要に応じて実装
    }
    
    /// モックをリセット
    static func reset() {
        requestHandler = nil
        lastRequest = nil
    }
}