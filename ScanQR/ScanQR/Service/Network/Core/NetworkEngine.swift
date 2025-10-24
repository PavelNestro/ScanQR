//
//  NetworkEngine.swift
//  ScanQR
//
//  Created by Pavel Nesterenko on 23.10.25.
//

import Foundation

protocol NetworkEngineProtocol {
    func request<T: Decodable>(endpoint: Endpoint, type: T.Type) async throws -> T
}

final class NetworkEngine: NetworkEngineProtocol {
    func request<T: Decodable>(endpoint: Endpoint, type: T.Type) async throws -> T {
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.baseURL
        components.path = endpoint.path
        components.queryItems = endpoint.parameters
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        if let body = endpoint.body {
            request.httpBody = body
            if let contentType = endpoint.headers?["Content-Type"] {
                request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            }
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Decode error: \(error)")
            print("Raw data:", String(data: data, encoding: .utf8) ?? "N/A")
            throw error
        }
    }
}
