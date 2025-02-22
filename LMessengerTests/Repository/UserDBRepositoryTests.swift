//
//  UserDBRepositoryTests.swift
//  LMessengerTests
//
//  Created by 김상민 on 2/23/25.
//

import XCTest
import Combine
@testable import LMessenger

final class UserDBRepositoryTests: XCTestCase {
    
    private var subscriptions = Set<AnyCancellable>()

    override func setUpWithError() throws { // 각 테스트가 실행되기 전에 호출되는 부분. 테스트 실행 전 필요한 준비를 할 수 있다.
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws { // 테스트가 종료되면 실행되는 부분. 테스트 종료 후 setUp에서 설정한 값을 해제할 수 있다.
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_getUser_succes() {
        let stubData = [
            "id": "user1_id",
            "name": "user1",
        ]
        
        let userDBRepository = UserDBRepository(reference: StubUserDBReference(value: stubData))
        
        // 동기적으로 테스트
        userDBRepository.getUser(userId: "user1_id")
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Unepected fail: \(error)")
                }
            } receiveValue: { userObject in
                XCTAssertNotNil(userObject)
                XCTAssertEqual(userObject.id, "user1_id")
                XCTAssertEqual(userObject.name, "user1")
            }.store(in: &subscriptions)
        
        // 비동기적으로 테스트
        /*
        let exp = XCTestExpectation(description: "getUser")
        
        userDBRepository.getUser(userId: "user1_id")
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Unepected fail: \(error)")
                }
            } receiveValue: { userObject in
                XCTAssertNotNil(userObject)
                XCTAssertEqual(userObject.id, "user1_id")
                XCTAssertEqual(userObject.name, "user1")
                exp.fulfill() // fulfill(작업 완료를 알림)이 됐을 때 해당되는 테스트가 진행이 될 수가 있습니다.?
            }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2) // 이 위치에서 해당되는 작업을 기다림
         */
    }

    func test_getUser_empty() {
        let userDBRepository = UserDBRepository(reference: StubUserDBReference(value: nil))
        
        userDBRepository.getUser(userId: "user1_id")
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error.localizedDescription, DBError.emptyValue.localizedDescription)
                }
            } receiveValue: { userObject in
                XCTFail("Unepected success: \(userObject)")
            }.store(in: &subscriptions)
    }
    
    func test_getUser_fail() {
        let stubData = [
            "id_nodified": "user1_id",
            "name_nodified": "user1",
        ]
        
        let userDBRepository = UserDBRepository(reference: StubUserDBReference(value: stubData))
        
        // 동기적으로 테스트
        userDBRepository.getUser(userId: "user1_id")
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTAssertNotNil(error)
                }
            } receiveValue: { userObject in
                XCTFail("Unepected success: \(userObject)")
            }.store(in: &subscriptions)
    }
}

struct StubUserDBReference: DBReferenceType {
    
    let value: Any?
    
    func setValue(key: String, path: String?, value: Any) -> AnyPublisher<Void, DBError> {
        Just(()).setFailureType(to: DBError.self).eraseToAnyPublisher()
    }
    
    func fetch(key: String, path: String?) -> AnyPublisher<Any?, DBError> {
        Just(value).setFailureType(to: DBError.self).eraseToAnyPublisher()
    }
    
    func setValue(key: String, path: String?, value: Any) async throws {
    }
    
    func setValues(_ values: [String : Any]) -> AnyPublisher<Void, LMessenger.DBError> {
        Just(()).setFailureType(to: DBError.self).eraseToAnyPublisher()
    }
    

    func fetch(key: String, path: String?) async throws -> Any? {
        return value
    }
    
    func filter(key: String, path: String?, orderedName: String, queryString: String) -> AnyPublisher<Any?, LMessenger.DBError> {
        Just(nil).setFailureType(to: DBError.self).eraseToAnyPublisher()
    }
    
    func childByAutoId(key: String, path: String?) -> String? {
        return nil
    }
    
    func observeChildAdded(key: String, path: String?) -> AnyPublisher<Any?, LMessenger.DBError> {
        Just(nil).setFailureType(to: DBError.self).eraseToAnyPublisher()
    }
    
    func removeObservedHandlers() {
    }
}
