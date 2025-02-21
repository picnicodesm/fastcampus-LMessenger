//
//  SearchDataController.swift
//  LMessenger
//
//

import Foundation
import CoreData

class SearchDataController: ObservableObject {
    
    let persistentContainer = NSPersistentContainer(name: "Search")
    
    init() {
        persistentContainer.loadPersistentStores { description, error in
            if let error {
                print("Core data failed: ", error)
            }
        }
    }
}
