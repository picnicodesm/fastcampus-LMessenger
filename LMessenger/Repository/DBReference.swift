//
//  DBReference.swift
//  LMessenger
//
//

import Foundation
import Combine
import FirebaseDatabase

protocol DBReferenceType {
    func setValue(key: String, path: String?, value: Any) -> AnyPublisher<Void, DBError>
    func setValue(key: String, path: String?, value: Any) async throws
    func setValues(_ values: [String: Any]) -> AnyPublisher<Void, DBError>
    func fetch(key: String, path: String?) -> AnyPublisher<Any?, DBError>
    func fetch(key: String, path: String?) async throws -> Any?
    func filter(key: String, path: String?, orderedName: String, queryString: String) -> AnyPublisher<Any?, DBError>
    func childByAutoId(key: String, path: String?) -> String?
    func observeChildAdded(key: String, path: String?) -> AnyPublisher<Any?, DBError>
    func removeObservedHandlers()
}

class DBReference: DBReferenceType {
    
    var db: DatabaseReference = Database.database().reference()
    
    var observedHandlers: [UInt] = []
    
    private func getPath(key: String, path: String?) -> String {
        if let path {
            return "\(key)/\(path)"
        } else {
            return key
        }
    }
    
    func setValue(key: String, path: String?, value: Any) -> AnyPublisher<Void, DBError> {
        let path = getPath(key: key, path: path)
        
        return Future<Void, DBError> { [weak self] promise in
            self?.db.child(path).setValue(value) { error, _ in
                if let error {
                    promise(.failure(.error(error)))
                } else {
                    promise (.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func setValue(key: String, path: String?, value: Any) async throws {
        try await db.child(getPath(key: key, path: path)).setValue(value)
    }
    
    func setValues(_ values: [String: Any]) -> AnyPublisher<Void, DBError> {
        Future<Void, DBError> { [weak self] promise in
            self?.db.updateChildValues(values) { error, _ in
                if let error {
                    promise(.failure(.error(error)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    
    func fetch(key: String, path: String?) -> AnyPublisher<Any?, DBError> {
        let path = getPath(key: key, path: path)
        
        return Future<Any?, DBError> { [weak self] promise in
            self?.db.child(path).getData { error, snapshot in
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
        }.eraseToAnyPublisher()
    }
    
    func fetch(key: String, path: String?) async throws -> Any? {
        try await db.child(getPath(key: key, path: path)).getData().value
    }
    
    func filter(key: String, path: String?, orderedName: String, queryString: String) -> AnyPublisher<Any?, DBError> {
        let path = getPath(key: key, path: path)
        
        return Future { [weak self] promise in
            self?.db.child(path)
                .queryOrdered(byChild: "name")
                .queryStarting(atValue: queryString)
                .queryEnding(atValue: queryString + "\u{f8ff}") // 유니코드의 제일 마지막 문자를 적어줘야 정상적인 결과가 나옵니다.
                .observeSingleEvent(of: .value) { snapshot in
                    promise(.success(snapshot.value))
                } // [String: [String: Any]]
        }.eraseToAnyPublisher()
    }
    
    func childByAutoId(key: String, path: String?) -> String? {
        db.child(getPath(key: key, path: path)).childByAutoId().key
    }
    
    func observeChildAdded(key: String, path: String?) -> AnyPublisher<Any?, DBError> {
        let subject = PassthroughSubject<Any?, DBError>()
       
        let handler = db.child(getPath(key: key, path: path)).observe(.childAdded) { snapshot in
            subject.send(snapshot.value)
        }
        
        observedHandlers.append(handler)
        
        return subject.eraseToAnyPublisher()
    }
    
    func removeObservedHandlers() {
        observedHandlers.forEach {
            db.removeObserver(withHandle: $0)
        }
    }

}
