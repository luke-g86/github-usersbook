//
//  Endpoints.swift
//  github-usersbook
//
//  Created by Lukasz on 27/07/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation

class APIEndpoints {
    
    enum baseURL {
        static let base = "https://api.github.com"
        
        case userSearch (String, Int)
        case userRepos (String)
        case userDetails (String)
        
        var stringUrlBody: String {
            switch self {
            case .userSearch (let query, let page): return baseURL.base + "/search/users?q=\(query)&page=\(page)&sort=login&order=asc"
            case .userRepos (let userName): return baseURL.base + "/users/\(userName)/repos"
            case .userDetails (let userName): return baseURL.base + "/\(userName)"
            }
        }
        var url: URL {
            return URL(string: stringUrlBody)!
        }
    }
    
    //MARK: - Main network connection
    
    // Generic structure of the network request
    
    class func getDataFromGithub<T: Decodable>(url: URL, response: T.Type, completion: @escaping (Result<T, DataFetchErrors>) -> Void) -> URLSessionTask {
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard let response = response as? HTTPURLResponse, response.connectionSuccessful, let data = data else {
                completion(Result.failure(.network))
                return
            }
            let decoder = JSONDecoder()
            do {
                let requestObject = try decoder.decode(T.self, from: data)
                completion(Result.success(requestObject))
            } catch {
                completion(Result.failure(.decoding))
                print(error.localizedDescription)
            }
        })
        task.resume()
        
        return task
    }
    
    class func downloadUsersAvatar(avatarURL: URL, completionHandler: @escaping (Data?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: avatarURL, completionHandler: { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(data, nil)
            }
        })
        task.resume()
    }
    
    // Network call for searchbar
    
    class func search(query: String, page: Int, completion: @escaping (Result<UsersSearch, DataFetchErrors>) -> Void) -> URLSessionTask {
        
        let task = getDataFromGithub(url: APIEndpoints.baseURL.userSearch(query, page).url, response: UsersSearch.self) { (response) in
            completion(response)
        }
        task.resume()
        
        return task
    }
}



