import SwiftUI
import CoreData

@MainActor
final class DetailViewModel: ObservableObject {
    @Published var code: ScannedCode
    @Published var titleText: String
    @Published var isEditing = false

    private var context: NSManagedObjectContext

    init(code: ScannedCode, context: NSManagedObjectContext) {
        self.code = code
        self.context = context
        self.titleText = code.title ?? ""
    }

    func saveChanges() {
        code.title = titleText
        do {
            try context.save()
            isEditing = false
            print("Изменения сохранены")
        } catch {
            print("Ошибка сохранения: \(error.localizedDescription)")
        }
    }
}
