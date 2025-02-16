//
//  NavigationRoutingView.swift
//  LMessenger
//
//  Created by 김상민 on 2/16/25.
//

import SwiftUI

struct NavigationRoutingView: View {
    @State var destination: NavigationDestination
    
    var body: some View {
        switch destination {
        case .chat:
            ChatView()
        case .search:
            SearchView()
        }
    }
}


