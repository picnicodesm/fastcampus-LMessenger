//
//  PushNotificationProvider.swift
//  LMessenger
//
//

import Foundation
import Combine

// 현재 코드는 이전 Cloud Messaging API를 이용하는데 맞춰 짜여진 코드이므로 동작하지 않음. HTTP v1으로 업데이트 해야함.
protocol PushNotificationProviderType {
    func sendPushNotification(object: PushObject) -> AnyPublisher<Bool, Never>
}

class PushNotificationProvider: PushNotificationProviderType {
    
    private let serverURL: URL = URL(string:"https://fcm.googleapis.com/fcm/send")! // 유효하지 않은 주소
    private let serverKey = "" // server key는 Oauth 토큰으로 변경됨
    
    func sendPushNotification(object: PushObject) -> AnyPublisher<Bool, Never> {
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorizaiton")
        request.httpBody = try? JSONEncoder().encode(object)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in true }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
