//
//  SettingItem.swift
//  LMessenger
//
//

import Foundation

protocol SettingItemable {
    var label: String { get }
}

struct SectionItem: Identifiable {
    let id = UUID()
    let label: String
    let settings: [SettingItem]
}

struct SettingItem: Identifiable {
    let id = UUID()
    let item: SettingItemable
}

/*
 모드 설정:
    시스템설정
    라이트모드
    다크모드
 
 계정:
    로그인
    로그아웃
 */
