//
//  PushObject.swift
//  LMessenger
//
//

import Foundation

// 현재 코드는 이전 Cloud Messaging API를 이용하는데 맞춰 짜여진 코드이므로 동작하지 않음. HTTP v1으로 업데이트 해야함.
struct PushObject: Encodable { // 요청을 보내는 body에 해당
    var to: String
    var notification: NotificationObject
    
    struct NotificationObject: Encodable {
        var title: String
        var body: String
    }
}
