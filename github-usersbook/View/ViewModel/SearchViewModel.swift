//
//  SearchViewModel.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 03/09/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation


protocol SearchViewModelDelegate: class {
    func fetchSucceeded(with newIndexPathsForTableView: [IndexPath]?)
    func fetchFailed(error reason: String)

}

class SearchViewModel {
    
    
    private weak var delegate: SearchViewModelDelegate?
    
    private var currentPage = 1
    private var totalEntries = 0
    var searchingUser: String?
    var itemsDownloaded: [Users] = []
    var isNetworkInProgress: Bool = false
    
    
    init(searchingUser:String?, delegate: SearchViewModelDelegate) {
        self.delegate = delegate
        self.searchingUser = searchingUser
    }
    
    func fetchSearchedUsers() {
        
        guard !isNetworkInProgress else {
            return
        }
        isNetworkInProgress = true
        
        guard let searchingUser = searchingUser else {return}
        APIEndpoints.search(query: searchingUser, page: currentPage) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isNetworkInProgress = false
                    self.delegate?.fetchFailed(error: error.details)
                }
                
            case .success(let response):
                DispatchQueue.main.async {
                    self.currentPage += 1
                    self.isNetworkInProgress = false
                    self.itemsDownloaded = response.items
                    
                    if response.totalCount > 30 {
                        let indexForTableView = self.calculateIndexPathsToRefreshTableView(self.itemsDownloaded)
                        self.delegate?.fetchSucceeded(with: indexForTableView)
                    } else {
                        
                        self.delegate?.fetchSucceeded(with: .none)
                    }
                }
            }
        }
    }
    
    private func calculateIndexPathsToRefreshTableView(_ itemsAdded: [Users]) -> [IndexPath] {
        let startIndex = itemsDownloaded.count - itemsAdded.count
        let endIndex = startIndex + itemsAdded.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0)}
    }
}
