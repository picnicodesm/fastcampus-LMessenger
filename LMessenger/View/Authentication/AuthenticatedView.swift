//
//  AuthenticatedView.swift
//  LMessenger
//
//

import SwiftUI

struct AuthenticatedView: View {
    @StateObject var authViewModel: AuthenticationViewModel
    @StateObject var navigationRouter: NavigationRouter
    @StateObject var searchDataController: SearchDataController
    @StateObject var appearanceController: AppearanceController
    
    var body: some View {
        VStack {
            switch authViewModel.authenticationState {
            case .unauthenticated:
                LoginIntroView()
                    .environmentObject(authViewModel)
            case .authenticated:
                MainTabView()
                    .environment(\.managedObjectContext, searchDataController.persistentContainer.viewContext)
                    .environmentObject(authViewModel)
                    .environmentObject(navigationRouter)
                    .environmentObject(appearanceController)
                    .onAppear {
                        authViewModel.send(action: .requestPushNotification)
                    }
            }
        }
        .onAppear {
            authViewModel.send(action: .checkAuthenticationState)
//            authViewModel.send(action: .logout)
        }
        .preferredColorScheme(appearanceController.appearance.colorScheme)
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView(authViewModel: .init(container: .init(services: StubService())), navigationRouter: .init(), searchDataController: .init(), appearanceController: .init(0))
    }
}

