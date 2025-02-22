//
//  SearchView.swift
//  LMessenger
//
//  Created by 김상민 on 2/12/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.managedObjectContext) var objectContext
    @StateObject var viewModel: SearchViewModel
    @AccessibilityFocusState var isSearchBarFocused: Bool
    
    var body: some View {
        VStack {
            topView
            
            if viewModel.searchResults.isEmpty {
                RecentSearchView { text in
                    viewModel.send(action: .setSearchText(text))
                    isSearchBarFocused = true
                }
            } else {
                List {
                    ForEach(viewModel.searchResults) { result in
                        HStack(spacing: 8) {
                            URLImageView(urlString: result.profileURL)
                                .frame(width: 26, height: 26)
                                .clipShape(Circle())
                            Text(result.name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.bkText)
                        }
                        .listRowInsets(.init())
                        .listRowSeparator(.hidden)
                        .padding(.horizontal, 30)
                    }
                }
                .listStyle(.plain)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    
    var topView: some View {
        HStack(spacing: 0) {
            Button {
                viewModel.send(action: .pop)
            } label: {
                Image("back_search")
            }
            
            SearchBar(text: $viewModel.searchText, shouldBecomeFirstResponder: $viewModel.shouldBecomeFirstresponder) {
                setSearchResultWithContext()
            }
            .accessibilityFocused($isSearchBarFocused)
            
            Button {
                viewModel.send(action: .clearSearchText)
            } label: {
                Image("close_search")
            }
        }
        .padding(.horizontal, 20)
    }
    
    func setSearchResultWithContext() {
        // environment로 가져온 managedObjectContext로 데이터를 저장하는 함수
        let result = SearchResult(context: objectContext)
        result.id = UUID().uuidString
        result.name = viewModel.searchText
        result.date = Date()
        
        try? objectContext.save()
    }
}

#Preview {
        SearchView(viewModel: .init(container: DIContainer(services: StubService()), userId: "user1_id"))
}
