//
//  ChatListViewModel.swift
//  LMessenger
//
//

import Foundation
import Combine

class ChatListViewModel: ObservableObject {
    
    enum Action {
        case load
    }
    
    @Published var chatRooms: [ChatRoom] = []
    
    private var container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    let userId: String
    
    init(container: DIContainer, userId: String) {
        self.container = container
        self.userId = userId
    }
    
    func send(action: Action) {
        switch action {
        case .load:
            container.services.chatRoomService.loadChatRooms(myUserId: userId)
                .sink { comletion in
                    
                } receiveValue: { [weak self] chatRooms in
                    self?.chatRooms = chatRooms
                }.store(in: &subscriptions)
        }
    }
}
