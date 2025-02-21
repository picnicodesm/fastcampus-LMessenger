//
//  AppearanceController.swift
//  LMessenger
//
//

import Foundation

class AppearanceController: ObservableObject {
    
    @Published var appearance: AppearanceType
    
    init(_ appearanceValue: Int) {
        self.appearance = AppearanceType(rawValue: appearanceValue) ?? .automatic
    }
    
    func changeAppearance(_ willBeAppearance: AppearanceType) {
        appearance = willBeAppearance
    }
}
