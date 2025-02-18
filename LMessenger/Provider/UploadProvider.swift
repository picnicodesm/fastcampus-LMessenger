//
//  UploadProvider.swift
//  LMessenger
//
//

import Foundation
import Combine
import FirebaseStorage
import FirebaseStorageCombineSwift // combine 지원

enum UploadError: Error {
    case error(Error)
}

protocol UploadProviderType {
    func upload(path: String, data: Data, fileName: String) -> AnyPublisher<URL, UploadError>
    func upload(path: String, data: Data, fileName: String) async throws -> URL
}

class UploadProvider: UploadProviderType {
    
    let storageRef = Storage.storage().reference() // 클라우드의 파일을 가리키는 포인터
    
    func upload(path: String, data: Data, fileName: String) -> AnyPublisher<URL, UploadError> {
        let ref = storageRef.child(path).child(fileName)
        
        return ref.putData(data)
            .flatMap { _ in
                ref.downloadURL()
            }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func upload(path: String, data: Data, fileName: String) async throws -> URL {
        let ref = storageRef.child(path).child(fileName)
        let _ = try await ref.putDataAsync(data) // storage는 async await을 지원함
        let url = try await ref.downloadURL()
        
        return url
    }
    
}
