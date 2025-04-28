//
//  Persistence.swift
//  ChooseGame
//
//  Created by Shepard on 28.04.2025.
//

    import CoreData

    class PersistenceController {
        static let shared = PersistenceController()

        let container: NSPersistentContainer

        init(inMemory: Bool = false) {
            container = NSPersistentContainer(name: "ChooseGame")
            if inMemory {
                container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            }
            container.loadPersistentStores { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
    }

