//
//  AppDelegate.swift
//  LMessenger
//
//  Created by 김상민 on 1/22/25.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        application.registerForRemoteNotifications()
        
        UNUserNotificationCenter.current().delegate = self
        
        FirebaseApp.configure()
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // application.registerForRemoteNotifications() 를 통해 APNs에 앱을 등록해달라고 요청하고 정상적으로 요청이 되면 디바이스 토큰이 이 메서드로 호출이 됨.
        // FCM을 이용한 경우에는 이 메서드가 필요 없음
        // SwiftUI로 앱을 빌드하는 경우에는 APNs 토큰을 명시적으로 FCM 등록 토큰에 맵핑을 해야 돼서 여기서 작업을 합니다.
        // (그럼 UIKit에서는  어떻게 하는지 찾아보기)
        Messaging.messaging().apnsToken = deviceToken
        print("token: ", deviceToken)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner]) // 이걸 해야 정상적으로 푸시가 옴
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler() // 푸시가 왔을 때 처리할 수 있는 메서드
    }
}
