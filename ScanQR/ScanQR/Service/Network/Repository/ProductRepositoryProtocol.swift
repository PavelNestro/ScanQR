import Foundation

protocol ProductRepositoryProtocol {
    func fetchProduct(by barcode: String) async throws -> ProductResponse
}
