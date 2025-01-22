//
//  AuthenticationViewModel.swift
//  LMessenger
//
//

import Foundation

enum AuthenticationState {
    case unauthenticated
    case authenticated
}

class AuthenticationViewModel: ObservableObject {
    @Published var authenticationState: AuthenticationState = .unauthenticated
    
    // DIContainer로 서비스 접근 예정
    
    private var container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
}
