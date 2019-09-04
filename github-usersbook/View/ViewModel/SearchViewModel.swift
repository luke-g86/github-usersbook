//
//  SearchViewModel.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 03/09/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation


protocol SearchViewModelDelegate: class {
    func fetchSucceeded()
    func fetchFailed(error reason: String)
    func downloadedUsers(with users: [Users])
    
}

class SearchViewModel {
    
    private weak var delegate: SearchViewModelDelegate?
    
    private var currentPage = 1
    private var totalEntries = 0
    var searchingUser: String
    var itemsDownloaded: [Users] = []
    

    
    init(searchingUser:String, delegate: SearchViewModelDelegate) {
        self.delegate = delegate
        self.searchingUser = searchingUser
    }
    
    func fetchSearchedUsers() {
        
        APIEndpoints.search(query: searchingUser, page: 1) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
                
            case .success(let response):
                DispatchQueue.main.async {
                    self.itemsDownloaded = response.items
                    self.delegate?.downloadedUsers(with: self.itemsDownloaded)
                }
        }
        
        }
    }
}
