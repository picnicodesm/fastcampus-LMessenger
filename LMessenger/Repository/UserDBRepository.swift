//
//  UserDBRepository.swift
//  LMessenger
//
//

import Foundation
import Combine

protocol UserDBRepositoryType {
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError>
    func addUserAfterContact(users: [UserObject]) -> AnyPublisher<Void, DBError>
    func getUser(userId: String) -> AnyPublisher<UserObject, DBError>
    func getUser(userId: String) async throws -> UserObject
    func loadUsers() -> AnyPublisher<[UserObject], DBError>
    func updateUser(userId: String, key: String, value: Any) -> AnyPublisher<Void, DBError>
    func updateUser(userId: String, key: String, value: Any) async throws
    func filterUsers(with queryString: String) -> AnyPublisher<[UserObject], DBError>
}

class UserDBRepository: UserDBRepositoryType {

    private let reference: DBReferenceType
    
    init(reference: DBReferenceType) {
        self.reference = reference
    }
    
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError> { // 해당되는 유저 정보를 인코딩을 해서 데이터화를 하고 그 데이터를 딕셔너리화를 한 다음 그 값을 경로에 데이터를 set 한 로직
        // object > data > dic
        Just(object)
            .compactMap { try? JSONEncoder().encode($0) }
            .compactMap { try? JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) }
            .flatMap { value in
                self.reference.setValue(key: DBKey.Users, path: object.id, value: value)
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
        // 스트림으로 users에 대한 정보를 딕셔너리화 할건데 이 앞에 유저 정보도 알아야 합니다.
        // 그래서 zip의 첫 번째 스트림은 유저 정보를 변환하지 않는 퍼블리셔, 그리고 두 번째 스트림은 변환을 하는 퍼블리셔. 이런 식으로 진행.
        
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
                self.reference.setValue(key: DBKey.Users, path: origin.id, value: converted)
            }
            .last()
            .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) -> AnyPublisher<UserObject, DBError> {
        reference.fetch(key: DBKey.Users, path: userId)
            .flatMap { value in
                if let value {
                    return Just(value)
                        .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                        .decode(type: UserObject.self, decoder: JSONDecoder())
                        .mapError { DBError.error($0) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: .emptyValue).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) async throws -> UserObject {
        // firebase realtimedatabse는 async를 지원함
        guard let value = try await reference.fetch(key: DBKey.Users, path: userId) else {
            throw DBError.emptyValue
        }
        
        let data = try JSONSerialization.data(withJSONObject: value)
        let userObject = try JSONDecoder().decode(UserObject.self, from: data)
        return userObject
    }

    
    func loadUsers() -> AnyPublisher<[UserObject], DBError> {
        reference.fetch(key: DBKey.Users, path: nil)
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
            } else {
                return Fail(error: .invalidatedType).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateUser(userId: String, key: String, value: Any) async throws {
        try await reference.setValue(key: DBKey.Users, path: "\(userId)/\(key)", value: value)
    }
    
    func updateUser(userId: String, key: String, value: Any) -> AnyPublisher<Void, DBError> {
        reference.setValue(key: key, path: "\(userId)/\(key)", value: value)
    }
    
    func filterUsers(with queryString: String) -> AnyPublisher<[UserObject], DBError> {

        reference.filter(key: DBKey.Users, path: nil, orderedName: "name", queryString: queryString)
        .flatMap { value in
            if let dic = value as? [String: [String: Any]] {
                return Just(dic)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: [String: UserObject].self, decoder: JSONDecoder())
                    .map { $0.values.map { $0 as UserObject } }
                    .mapError { DBError.error($0) }
                    .eraseToAnyPublisher()
            } else if value == nil {
                return Just([]).setFailureType(to: DBError.self).eraseToAnyPublisher()
            } else {
                return Fail(error: .invalidatedType).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
        
    }
}
