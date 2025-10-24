import Foundation

struct ProductResponse: Decodable {
    let status: Int
    let code: String
    let product: Product?
}

struct Product: Decodable, Identifiable {
    var id: String { code }
    let code: String
    let productName: String?
    let brands: String?
    let ingredientsText: String?
    let nutriscoreGrade: String?

    
    private enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case brands
        case ingredientsText = "ingredients_text"
        case nutriscoreGrade = "nutriscore_grade"
    }
}
