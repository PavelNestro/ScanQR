import Foundation

protocol Endpoint {
    var scheme: String { get }
    var baseURL: String { get }
    var path: String { get }
    var method: String { get }
    var parameters: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

extension Endpoint {
    var headers: [String: String]? { nil }
    var parameters: [URLQueryItem]? { nil }
    var body: Data? { nil }
}
