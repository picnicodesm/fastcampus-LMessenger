//
//  ChatViewModel.swift
//  LMessenger
//
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    
    enum Action {
        
    }
    
    @Published var chatDataList: [ChatData] = []
    @Published var myUser: User?
    @Published var otherUser: User?
    @Published var message: String = ""
    
    private let chatRoomdId: String
    private let myUserId: String
    private let otherUserId: String
    
    private var container: DIContainer
    private var subscription = Set<AnyCancellable>()
    
    init(container: DIContainer, chatRoomId: String, myUserId: String, otherUserId: String) {
        self.container = container
        self.chatRoomdId = chatRoomId
        self.myUserId = myUserId
        self.otherUserId = otherUserId
    }
    
    func updateChatDataList(_ chat: Chat) {
        let key = chat.date.toChatDataKey
        
        if let index = chatDataList.firstIndex(where: { $0.dateStr == key }) {
            chatDataList[index].chats.append(chat)
        } else {
            let newChatData: ChatData = .init(dateStr: key, chats: [chat])
            chatDataList.append(newChatData)
        }
    }
    
    func getDirection(id: String) -> ChatItemDirection {
        myUserId == id ? .right : .left
    }
    
    func send(action: Action) {
        
    }
}
/*
 Chats/
    ChatRoomId/
        chatId1/Chat
        chatId1/Chat
        chatId1/Chat
 
 Chat Date > 2023.11.1
 Chat Date > 2023.11.1
 Chat Date > 2023.11.1
 Chat Date > 2023.11.3
 */
