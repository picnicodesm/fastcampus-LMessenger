//
//  SearchDataController.swift
//  LMessenger
//
//

import Foundation
import CoreData

protocol DataControllable {
    var persistentContainer: NSPersistentContainer { get set }
}

class SearchDataController: ObservableObject, DataControllable {
    
    var persistentContainer = NSPersistentContainer(name: "Search")
    
    init() {
        persistentContainer.loadPersistentStores { description, error in
            if let error {
                print("Core data failed: ", error)
            }
        }
    }
}
