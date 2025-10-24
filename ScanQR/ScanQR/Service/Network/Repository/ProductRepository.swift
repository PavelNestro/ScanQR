import Foundation

final class ProductRepository: ProductRepositoryProtocol {
    private let network: NetworkEngineProtocol
    
    init(network: NetworkEngineProtocol = NetworkEngine()) {
        self.network = network
    }
    
    func fetchProduct(by barcode: String) async throws -> ProductResponse {
        try await network.request(
            endpoint: OpenFoodFactsEndpoint.product(barcode: barcode),
            type: ProductResponse.self
        )
    }
}
