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
        
        case userSearch (String)
        
        var stringUrlBody: String {
            switch self {
            case .userSearch (let query): return baseURL.base + "/search/users?q=\(query)"
            }
        }
        var url: URL {
            return URL(string: stringUrlBody)!
        }
    }
    
    class func getDataFromGithub<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let requestObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(requestObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                    print(error)
                }
            }
        }
        task.resume()
        return task
    }
}



