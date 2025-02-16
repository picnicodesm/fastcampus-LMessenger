//
//  UserDBRepository.swift
//  LMessenger
//
//

import Foundation
import Combine
import FirebaseDatabase

protocol UserDBRepositoryType {
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError>
    func getUser(userId: String) -> AnyPublisher<UserObject, DBError>
    func getUser(userId: String) async throws -> UserObject
    func updateUser(userId: String, key: String, value: Any) async throws
    func loadUsers() -> AnyPublisher<[UserObject], DBError>
    func addUserAfterContact(users: [UserObject]) -> AnyPublisher<Void, DBError>
}

class UserDBRepository: UserDBRepositoryType {
    
    var db: DatabaseReference = Database.database().reference() // reference는 database에서 root 역할
    
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError> { // 해당되는 유저 정보를 인코딩을 해서 데이터화를 하고 그 데이터를 딕셔너리화를 한 다음 그 값을 경로에 데이터를 set 한 로직
        // object > data > dic
        Just(object)
            .compactMap { try? JSONEncoder().encode($0) }
            .compactMap { try? JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) }
            .flatMap { value in
                Future<Void, Error> { [weak self] promise in // Users/userId/ ..
                    self?.db.child(DBKey.Users).child(object.id).setValue(value) { error, _ in
                        if let error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
            .mapError { DBError.error($0) }
            .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) -> AnyPublisher<UserObject, DBError> {
        Future<Any?, DBError> { [weak self] promise in
            self?.db.child(DBKey.Users).child(userId).getData { error, snapshot in
                // firebase에서 데이터를 조회하는 방법은 여러가지가 있는데 여기선 getData 사용
                if let error {
                    promise(.failure(DBError.error(error)))
                } else if snapshot?.value is NSNull {
                    // 만약에 db에 해당유저 정보가 없는지를 체크를 하려면 스냅샷.value에 결과 object가 들어있는데 없을 경우 nil이 아니라 NSNull을 가짐
                    // NSNull일 경우 nil을 아웃풋으로 넘겨주어야 함
                    promise(.success(nil))
                } else {
                    promise(.success(snapshot?.value)) // snapshot.vlaue: dictionary ==> data화 ==> decorder로 파싱
                }
            }
        }.flatMap { value in
            if let value {
                return Just(value)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: UserObject.self, decoder: JSONDecoder())
                    .mapError { DBError.error($0) }
                    .eraseToAnyPublisher()
            } else {
                // 유저에 대한 정보가 없을 때에는 실패가 맞으므로
                return Fail(error: .emptyValue).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) async throws -> UserObject {
        // firebase realtimedatabse는 async를 지원함
        guard let value = try await self.db.child(DBKey.Users).child(userId).getData().value else {
            throw DBError.emptyValue
        }
        
        let data = try JSONSerialization.data(withJSONObject: value)
        let userObejct = try JSONDecoder().decode(UserObject.self, from: data)
        return userObejct
    }
    
    func updateUser(userId: String, key: String, value: Any) async throws {
        try await self.db.child(DBKey.Users).child(userId).child(key).setValue(value)
    }
    
    func loadUsers() -> AnyPublisher<[UserObject], DBError> {
        Future<Any?, DBError> { [weak self] promise in
            self?.db.child(DBKey.Users).getData { error, snapshot in
                if let error {
                    promise(.failure(DBError.error(error)))
                } else if snapshot?.value is NSNull {
                    promise(.success(nil))
                } else {
                    promise(.success(snapshot?.value))
                }
            }
        }
        .flatMap { value in
            if let dic = value as? [String: [String: Any]] {
                return Just(dic)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0)}
                    .decode(type: [String: UserObject].self, decoder: JSONDecoder())
                    .map { $0.values.map { $0 as UserObject } } // values 안에 있는 값이 UserObject인지 자동으로 추론화가 안되기 떄문에 map으로 명시
                    .mapError { DBError.error($0) }
                    .eraseToAnyPublisher()
            } else if value == nil {
                return Just([]).setFailureType(to: DBError.self).eraseToAnyPublisher()
                // Just는 에러 타입이 Never라서 명시적으로 실패 타입을 지정해주기 위해 setFailureType 사용
            } else {
                return Fail(error: .invalidatedType).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addUserAfterContact(users: [UserObject]) -> AnyPublisher<Void, DBError> {
        /*
         Users/
            user_id: [String: Any]
            user_id: [String: Any]
            user_id: [String: Any]
         */
        // 스트림으로 users에 대한 정보를 딕셔너리화 할건데 우리는 이 앞에 유저 정보도 알아야 합니다.
        // 그래서 zip의 첫 번째 스트림은 유저 벙보를 변환하지 않는 퍼블리셔, 그리고 두 번째 스트림은 변환을 하는 퍼블리셔. 이런 식으로 진행해보겠습니다.
        
        Publishers.Zip(users.publisher, users.publisher)
            .compactMap { origin, converted in
                if let converted = try? JSONEncoder().encode(converted) {
                    return (origin, converted)
                } else {
                    return nil
                }
            }
            .compactMap { origin, converted in
                if let converted = try? JSONSerialization.jsonObject(with: converted, options: .fragmentsAllowed) {
                    return (origin, converted)
                } else {
                    return nil
                }
            }
            .flatMap { origin, converted in
                Future<Void, Error> { [weak self] promise in
                    self?.db.child(DBKey.Users).child(origin.id).setValue(converted) { error, _ in
                        if let error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                        
                    }
                }
            }
            .last()
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
}
