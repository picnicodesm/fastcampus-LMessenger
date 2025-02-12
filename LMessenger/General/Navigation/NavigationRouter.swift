//
//  NavigationRouter.swift
//  LMessenger
//
//

import Foundation

class NavigationRouter: ObservableObject {
    
    @Published var destinations: [NavigationDestination] = []
    
    func push(to view: NavigationDestination) {
        destinations.append(view)
    }
    
    func pop() {
        _ = destinations.popLast()
    }
    
    func popToRootView() {
        destinations = []
    }
}
