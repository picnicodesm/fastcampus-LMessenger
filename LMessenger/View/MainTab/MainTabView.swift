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
                        HomeView(viewModel: .init(container: container, userId: authViewModel.userId ?? "")) // 조금 더 실전이면 옵셔널을 홈 뷰 진입 전 한 번 더 체크할만 함
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

//struct MainTabView_Previews: PreviewProvider {
//    static let container = DIContainer(services: StubService())
//    
//    static var previews: some View {
//        MainTabView()
//            .environmentObject(self.container)
//            .environmentObject(AuthenticationViewModel(container: self.container))
//    }
//}

#Preview {
    let container = DIContainer(services: StubService())
    
    MainTabView()
        .environmentObject(container)
        .environmentObject(AuthenticationViewModel(container: container))
}
