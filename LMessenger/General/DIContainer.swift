//
//  DIContainer.swift
//  LMessenger
//
//

import Foundation

class DIContainer: ObservableObject {
    var services: ServiceType
    
    init(services: ServiceType) {
        self.services = services
    }
}
