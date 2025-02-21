//
//  SearchBar.swift
//  LMessenger
//
//

import SwiftUI

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    @Binding var shouldBecomeFirstResponder: Bool
    var onClickedSearchButton: (() -> Void)?
    
    init(text: Binding<String>,
         shouldBecomeFirstResponder: Binding<Bool>,
         onClickedSearchButton: (() -> Void)?) {
        self._text = text
        self._shouldBecomeFirstResponder = shouldBecomeFirstResponder
        self.onClickedSearchButton = onClickedSearchButton
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, shouldBecomeFirstResponder: $shouldBecomeFirstResponder, onClickedSearchButton: onClickedSearchButton)
    }
    
    func makeUIView(context: Context) -> UISearchBar { // 원래는 some View인데 여기서는 searchBar임이 명확하므로 UISearchBar로 변경
        let searchBar = UISearchBar(frame: .zero)
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ searchBar: UISearchBar, context: Context) {
        updateBecomeFirstResponder(searchBar, context: context)
        updateSearchText(searchBar, context: context)
    }
    
    private func updateSearchText(_ searchBar: UISearchBar, context: Context) {
        context.coordinator.setSearchText(searchBar, text: text)
    }
    
    private func updateBecomeFirstResponder(_ searchBar: UISearchBar, context: Context) {
        guard searchBar.canBecomeFirstResponder else { return }
        
        DispatchQueue.main.async {
            if shouldBecomeFirstResponder {
                guard !searchBar.isFirstResponder else { return }
                searchBar.becomeFirstResponder()
            } else {
                guard searchBar.isFirstResponder else { return }
                searchBar.resignFirstResponder()
            }
        }
    }
}

extension SearchBar {
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        @Binding var shouldBecomeFirstResponder: Bool
        var onClickedSearchButton: (() -> Void)?
        
        init(text: Binding<String>,
             shouldBecomeFirstResponder: Binding<Bool>,
             onClickedSearchButton: (() -> Void)?) {
            self._text = text
            self._shouldBecomeFirstResponder = shouldBecomeFirstResponder
            self.onClickedSearchButton = onClickedSearchButton
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.text = searchText
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.shouldBecomeFirstResponder = true
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            self.shouldBecomeFirstResponder = false
        } // 이 작업을 안하면 shouldBecomeFirstResponder가 동기화가 안되있으면 searchbar가 resign이 될 수도 있음
        
        func setSearchText(_ searchBar: UISearchBar, text: String) {
            searchBar.text = text
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            onClickedSearchButton!()
        }
    }
}
