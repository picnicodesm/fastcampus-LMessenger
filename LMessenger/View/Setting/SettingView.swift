//
//  SettingView.swift
//  LMessenger
//
//

import SwiftUI

struct SettingView: View {
    @AppStorage(AppStorageType.Appearance) var appearance: Int = UserDefaults.standard.integer(forKey: AppStorageType.Appearance) // 해당 프로퍼티로 userDefault의 값을 읽고 쓸 수 있는 상태가 됨.
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appearanceController: AppearanceController
    @StateObject var viewModel: SettingViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.sectionItems) { section in
                    Section {
                        ForEach(section.settings) { setting in
                            Button {
                                if let a = setting.item as? AppearanceType {
                                    appearanceController.changeAppearance(a)
                                    appearance = a.rawValue
                                }
                            } label: {
                                Text(setting.item.label)
                                    .foregroundColor(.bkText)
                            }
                        }
                    } header: {
                        Text(section.label)
                    }
                }
            }
            .navigationTitle("설정")
            .toolbar {
                Button {
                    dismiss()
                } label: {
                    Image("close_search")
                }
            }
        }
        .preferredColorScheme(appearanceController.appearance.colorScheme)
    }
}

#Preview {
    SettingView(viewModel: .init())
}
