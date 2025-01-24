//
//  HomeViewModel.swift
//  LMessenger
//
//

import Foundation

class HomeViewModel: ObservableObject {
    
    @Published var myUser: User?
    @Published var users: [User] = [.stub, .stub2]
}
