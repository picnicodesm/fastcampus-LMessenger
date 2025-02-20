//
//  PushNotificationService.swift
//  LMessenger
//
//

import Foundation
import FirebaseMessaging
import Combine

protocol PushNotificationServiceType {
    var fcmToken: AnyPublisher<String?, Never> { get }
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func sendPushNotification(fcmToken: String, message: String) -> AnyPublisher<Bool, Never>
}

class PushNotificationService: NSObject, PushNotificationServiceType {
    
    var provider: PushNotificationProviderType
    
    var fcmToken: AnyPublisher<String?, Never> {
        _fcmToken.eraseToAnyPublisher() // 외부에서는 읽기만 가능하게 하여 외부에서 send를 할 수 없게 만듦
    }
    
    private let _fcmToken = CurrentValueSubject<String?, Never>(nil)
    
    init(provider: PushNotificationProviderType) {
        self.provider = provider
        super.init()
        
        Messaging.messaging().delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            // Bool 값은 권한을 정상적으로 획득했다라는 의미,
            if error != nil {
                completion(false)
            } else {
                completion(granted)
            }
        }
    }
    
    func sendPushNotification(fcmToken: String, message: String) -> AnyPublisher<Bool, Never> {
        provider.sendPushNotification(object: .init(to: fcmToken, notification: .init(title: "L사메신저앱", body: message)))
    }
}

extension PushNotificationService: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // 정상적으로 등록이 되었을 때 FCM 토큰을 리턴해주는 메서드
        // 이 메서드가 호출되는 시점은 권한이 되기 전일 것(등록은 App이 켜지면서 되는 것이기 때문인가)
        // 그래서 이 토큰을 가지고 있을 수 있는 currentSubject 생성
        print("messaging:didReceiveRegistrationToken:", fcmToken ?? "")
        
        guard let fcmToken else { return }
        
        _fcmToken.send(fcmToken)
    }
}

class StubPushNotificationService: PushNotificationServiceType {
    var fcmToken: AnyPublisher<String?, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
    }
    
    func sendPushNotification(fcmToken: String, message: String) -> AnyPublisher<Bool, Never> {
        Empty().eraseToAnyPublisher()
    }
}
