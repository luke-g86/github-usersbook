//
//  UsersRepositories.swift
//  github-usersbook
//
//  Created by Lukasz on 28/07/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation


struct ReposSearch: Codable {
    
    let totalCount: Int
    let incompleteResults: Bool
    let items: [UsersRepositories]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct UsersRepositories: Codable {
    
// Not using info about the owner
    
    let name: String?
//    let owner: Owner?
    let description: String?
    let createdAt: String?
//    let updatedAt: String?
    let stargazersCount: Int?
    let watchersCount: Int?
    let language: String?
    let watchers: Int?
    
    enum CodingKeys: String, CodingKey {
        
        case name
//        case owner
        case description
        case createdAt = "created_at"
//        case updatedAt = "updated_at"
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case language
        case watchers
    }
}

// In case owner data are necessary

struct Owner: Codable {
    
    let login: String?
    let id: Int?
    let nodeId: String?
    let avatarUrl: String?
    let gravatarUrl: String?
    let url: String?
    let htmlUrl: String?
    let followersUrl: String?
    let followingUrl: String?
    let gistsUrl: String?
    let starredUrl: String?
    let subscriptionsUrl: String?
    let organizationsUrl: String?
    let reposUrl: String?
    let eventsUrl: String?
    let receivedEventsUrl: String?
    let type: String?
    let siteAdmin: Bool?
    
    enum CodingKeys: String, CodingKey {
        
        case login
        case id
        case nodeId = "node_id"
        case avatarUrl = "avatar_url"
        case gravatarUrl = "gravatar_url"
        case url
        case htmlUrl = "html_url"
        case followersUrl = "followers_url"
        case followingUrl = "following_url"
        case gistsUrl = "gists_url"
        case starredUrl = "starred_url"
        case subscriptionsUrl = "subscriptions_url"
        case organizationsUrl = "organizations_url"
        case reposUrl = "repos_url"
        case eventsUrl = "events_url"
        case receivedEventsUrl = "received_events_url"
        case type
        case siteAdmin = "site_admin"
        
    }
    
}
