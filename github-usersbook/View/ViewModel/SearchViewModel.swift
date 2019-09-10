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
    func fetchedUsers(with users: [Users]?)
}

class SearchViewModel {
    
    
    private weak var delegate: SearchViewModelDelegate?

    private var currentPage = 1
    private var totalEntries = 0
    private var page: Int {
        if searchCompleted {
            currentPage = 1
            return currentPage
        } else {
            return currentPage
        }
    }
    
    private var itemsDownloaded: [Users] = []
    private var isNetworkInProgress: Bool = false
    
    var searchCompleted: Bool = false
    var searchingUser: String?
    
    
    var itemsDownloadedCount: Int { return itemsDownloaded.count }
    var totalCount: Int { return totalEntries }
    
    init(searchingUser:String?, delegate: SearchViewModelDelegate) {
        self.delegate = delegate
        self.searchingUser = searchingUser
    }
    
    func fetchSearchedUsers() {
        
        guard !isNetworkInProgress else {
            print("Network in progress \(isNetworkInProgress)")
            return
        }
        isNetworkInProgress = true
        
        guard let searchingUser = searchingUser else {return}
        
        print("searching")
        
        _ = APIEndpoints.search(query: searchingUser, page: page) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isNetworkInProgress = false
                    self.delegate?.fetchFailed(error: error.details)
                }
                
            case .success(let response):
                print("search is completed: \(self.searchCompleted)")
                print("number of page \(self.page)")
                print("current page \(self.currentPage)")
                DispatchQueue.main.async {
                    self.currentPage += 1
                    self.isNetworkInProgress = false
                    self.itemsDownloaded = response.items
                    self.totalEntries = response.totalCount
                    self.delegate?.fetchedUsers(with: self.itemsDownloaded)
                    
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
