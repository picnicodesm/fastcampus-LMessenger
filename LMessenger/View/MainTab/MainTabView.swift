//
//  MainTabView.swift
//  LMessenger
//
//  Created by 김상민 on 1/22/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var container: DIContainer
    @State private var selectedTab: MainTabType = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(MainTabType.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .home:
                        HomeView(viewModel: .init(container: container, userId: authViewModel.userId ?? ""))
                    case .chat:
                        ChatListView(viewModel: .init(container: container, userId: authViewModel.userId ?? ""))
                    case .phone:
                        Color.blackFix
                    }
                }
                .tabItem {
                    Label(tab.title, image: tab.imageName(selected: selectedTab == tab))
                }
                .tag(tab)
            }
        }
        .tint(.bkText)
    }
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.bkText)
    }
}

#Preview {
    let container = DIContainer(services: StubService())
    
    MainTabView()
        .environmentObject(container)
        .environmentObject(AuthenticationViewModel(container: container))
}
