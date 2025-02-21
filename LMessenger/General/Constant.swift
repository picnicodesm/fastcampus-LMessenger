//
//  Constant.swift
//  LMessenger
//
//

import Foundation

typealias DBKey = Constant.DBKey
typealias AppStorageType = Constant.AppStorage

enum Constant { } // 여러 개의 상수 타입이 있을 수 있으므로 네임스페이싱을 만들고 extension으로 구현

extension Constant {
    struct DBKey {
        static let Users = "Users"
        static let ChatRooms = "ChatRooms"
        static let Chats = "Chats"
    }
}

extension Constant {
    struct AppStorage {
        static let Appearance = "AppStorage_Appearance"
    }
}


