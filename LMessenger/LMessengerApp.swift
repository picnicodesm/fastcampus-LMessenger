//
//  LMessengerApp.swift
//  LMessenger
//
//

import SwiftUI

@main
struct LMessengerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var container: DIContainer = .init(services: Services())
    
    var body: some Scene {
        WindowGroup {
            AuthenticatedView(authViewModel: .init(container: container), navigationRouter: .init()) // 이 구조는 뷰 또는 뷰모델을 테스트할 때 원하는 행태를 주입하여 테스트가 가능합니다.
                .environmentObject(container)
        }
    }
}
