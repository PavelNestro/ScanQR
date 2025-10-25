import CoreData

final class CodeRepository {
     let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func saveCode(code: String, title: String) {
        context.perform {
            let request = ScannedCode.fetchRequest()
            request.predicate = NSPredicate(format: "codeValue == %@", code)

            if let existing = try? self.context.fetch(request).first {
                print("Код уже сохранён:", existing.codeValue ?? "")
                return
            }

            let newCode = ScannedCode(context: self.context)
            newCode.id = UUID()
            newCode.codeValue = code
            newCode.title = title
            newCode.scannedAt = Date()

            Task {
                if code.allSatisfy(\.isNumber), code.count >= 8 {
                    do {
                        let response = try await ProductRepository().fetchProduct(by: code)
                        if let product = response.product {
                            await MainActor.run {
                                newCode.title = product.productName ?? title
                                newCode.brand = product.brands
                                newCode.ingredients = product.ingredientsText
                                newCode.nutriScore = product.nutriscoreGrade
                            }
                        }
                    } catch {
                        print("Ошибка загрузки продукта:", error.localizedDescription)
                    }
                }

                do {
                    try self.context.save()
                    print("Сохранено:", newCode.title ?? "-")
                } catch {
                    print("Ошибка сохранения в Core Data:", error.localizedDescription)
                }
            }
        }
    }
}
