//
//  MemoryStorage.swift
//  LMessenger
//
//

import UIKit

protocol MemoryStorageType {
    func value(for key: String) -> UIImage? // cache에서 값을 가져올 수 있는 함수
    func store(for key: String, image: UIImage) // cache에 저장하는 함수
}

class MemoryStorage: MemoryStorageType {
    
    var cache = NSCache<NSString, UIImage>()
    
    func value(for key: String) -> UIImage? {
        cache.object(forKey: NSString(string: key))
    }
    
    func store(for key: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: key)) // cost도 파라미터로 넣을 수 있는데 바이트 단위의 용량제한 설정. 기본적으로 NSCache는 자체 메모리를 관리하는 정책을 갖고 있습니다. 따라서 cost를 설정해줘야 그만큼 작업이 가능하여 실제 작업할 떄에는 원하는 용량을 세팅해줘야 합니다.
    }
}
