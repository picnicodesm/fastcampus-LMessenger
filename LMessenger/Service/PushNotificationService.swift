//
//  PushNotificationService.swift
//  LMessenger
//
//

import Foundation
import FirebaseMessaging

protocol PushNotificationServiceType {
    func requestAuthorization(completion: @escaping (Bool) -> Void)
}

class PushNotificationService: NSObject, PushNotificationServiceType {
    
    override init() {
        super.init()
        
        Messaging.messaging().delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            // Bool 값은 권한을 정상적으로 획득했다라는 의미,
            if let error {
                completion(false)
            } else {
                completion(granted)
            }
        }
    }
}

extension PushNotificationService: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // 정상적으로 등록이 되었을 때 FCM 토큰을 리턴해주는 메서드
        print("messaging:didReceiveRegistrationToken:", fcmToken ?? "")
    }
}

class StubPushNotificationService: PushNotificationServiceType {
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        
    }
}
