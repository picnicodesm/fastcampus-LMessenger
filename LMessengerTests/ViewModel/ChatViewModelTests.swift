//
//  ChatViewModelTests.swift
//  LMessengerTests
//
//  Created by 김상민 on 2/23/25.
//

import XCTest
import Combine
@testable import LMessenger

final class ChatViewModelTests: XCTestCase {

    private var subscriptions = Set<AnyCancellable>()

    override func setUpWithError() throws {
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
    }
    
    func test_addChat_equal_date() {
        
        let viewModel: ChatViewModel = .init(container: DIContainer.stub, chatRoomId: "chatRoom1_id", myUserId: "user1_id", otherUserId: "user2_id")
        
        let date = Date(year: 2025, month: 2, day: 23)!
        viewModel.updateChatDataList(.init(chatId: "chat1_id", userId: "user1_id", date: date))
        viewModel.updateChatDataList(.init(chatId: "chat1_id", userId: "user1_id", date: date))
        viewModel.updateChatDataList(.init(chatId: "chat1_id", userId: "user1_id", date: date))
        viewModel.updateChatDataList(.init(chatId: "chat1_id", userId: "user1_id", date: date))
        
        XCTAssertEqual(viewModel.chatDataList.count, 1)
        XCTAssertEqual(viewModel.chatDataList[0].chats.count, 4)
    }
    
    func test_addChat_not_equal_date() {
        let viewModel: ChatViewModel = .init(container: DIContainer.stub, chatRoomId: "chatRoom1_id", myUserId: "user1_id", otherUserId: "user2_id")
        
        var date = Date(year: 2025, month: 2, day: 23)!
        viewModel.updateChatDataList(.init(chatId: "chat1_id", userId: "user1_id", date: date))
        viewModel.updateChatDataList(.init(chatId: "chat1_id", userId: "user1_id", date: date))
        date = date.addingTimeInterval(24 * 60 * 60)
        viewModel.updateChatDataList(.init(chatId: "chat1_id", userId: "user1_id", date: date))
        date = date.addingTimeInterval(24 * 60 * 60)
        viewModel.updateChatDataList(.init(chatId: "chat1_id", userId: "user1_id", date: date))
        
        XCTAssertEqual(viewModel.chatDataList.count, 3)
        XCTAssertEqual(viewModel.chatDataList[0].chats.count, 2)
        XCTAssertEqual(viewModel.chatDataList[1].chats.count, 1)
        XCTAssertEqual(viewModel.chatDataList[2].chats.count, 1)
        
    }
}
