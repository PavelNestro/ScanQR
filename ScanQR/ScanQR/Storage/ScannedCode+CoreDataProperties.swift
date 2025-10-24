import Foundation
import CoreData

extension ScannedCode {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScannedCode> {
        return NSFetchRequest<ScannedCode>(entityName: "ScannedCode")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var codeValue: String?
    @NSManaged public var title: String?
    @NSManaged public var brand: String?
    @NSManaged public var ingredients: String?
    @NSManaged public var nutriScore: String?
    @NSManaged public var scannedAt: Date?

}

extension ScannedCode: Identifiable {}
