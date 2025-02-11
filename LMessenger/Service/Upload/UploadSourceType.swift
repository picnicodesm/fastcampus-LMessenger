//
//  UploadSourceType.swift
//  LMessenger
//
//

import Foundation

enum UploadSourceType {
    case chat(chatRoomId: String)
    case profile(userId: String)
    
    var path: String {
        switch self {
        case let .chat(chatRoomId): // Chats/chatRoomId
            return "\(DBKey.Chats)/\(chatRoomId)"
        case let .profile(userId): // Users/UserId/
            return "\(DBKey.Users)/\(userId)"
        }
    }
}
