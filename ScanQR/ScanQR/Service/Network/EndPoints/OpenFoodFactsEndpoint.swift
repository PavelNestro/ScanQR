
import Foundation

enum OpenFoodFactsEndpoint: Endpoint {
    case product(barcode: String)
    
    var scheme: String { APIConfig.scheme }
    var baseURL: String { APIConfig.baseURL }
    
    var path: String {
        switch self {
        case .product(let barcode):
            return "/api/v0/product/\(barcode).json"
        }
    }
    
    var method: String { "GET" }
}
