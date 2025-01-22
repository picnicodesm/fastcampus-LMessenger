//
//  Services.swift
//  LMessenger
//
//

import Foundation

// 인증 서비스의 틀
protocol ServiceType {
    var authService: AuthenticatoinServiceType { get set }
}

class Services: ServiceType {
    var authService: AuthenticatoinServiceType
    
    init() {
        self.authService = AuthenticatoinService()
    }
}

class StubService: ServiceType {
    var authService: AuthenticatoinServiceType = StubAuthenticatoinService()
}
