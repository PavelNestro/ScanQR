//
//  Persistence.swift
//  ScanQR
//
//  Created by Pavel Nesterenko on 23.10.25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        //тест
        let sample = ScannedCode(context: context)
        sample.id = UUID()
        sample.codeValue = "1234567890123"
        sample.title = "Demo Product"
        sample.brand = "Sample Brand"
        sample.ingredients = "Water, Sugar"
        sample.nutriScore = "B"
        sample.scannedAt = Date()
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved Core Data error \(nsError), \(nsError.userInfo)")
        }
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ScanQR")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data load error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
