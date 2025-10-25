import Foundation
import AVFoundation

/// Тип кода — QR или штрих-код
enum CodeType: String, Codable {
    case qr = "QR"
    case barcode = "Barcode"
    case unknown = "Unknown"
}

/// Модель, описывающая результат сканирования
struct ScannedItem: Identifiable, Codable, Equatable {
    var id = UUID()
    let value: String
    let type: CodeType
    let date: Date
    
    /// Определяет тип кода по AVMetadataObjectType
    static func fromMetadata(_ object: AVMetadataMachineReadableCodeObject) -> ScannedItem? {
        guard let codeValue = object.stringValue else { return nil }
        
        let type: CodeType
        switch object.type {
        case .qr:
            type = .qr
        case .ean13, .ean8, .code128:
            type = .barcode
        default:
            type = .unknown
        }
        
        return ScannedItem(value: codeValue, type: type, date: Date())
    }
}
