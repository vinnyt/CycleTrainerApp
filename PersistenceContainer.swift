//
//  PersistanceContainer.swift
//  PersistanceContainer
//
//  Created by Allen Liang on 9/5/21.
//

import CoreData

struct PersistenceContainer {
    static let shared = PersistenceContainer()
    
    let container: NSPersistentContainer
    
    init() {
//        ValueTransformer.setValueTransformer(TrackPointTransformer(), forName: .trackPointTransformer)
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
}
