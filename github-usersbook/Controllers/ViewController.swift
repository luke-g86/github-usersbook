//
//  ViewController.swift
//  github-usersbook
//
//  Created by Lukasz on 27/07/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _ = getUser { (users, error) in
            if let users = users {
                for a in users {
                    print(a)
                }
            } else {
                print(error)
            }
            
        }
        
    }
    
    
    func getUser(completion: @escaping ([User]?, Error?) -> Void) {
        APIEndpoints.getDataFromGithub(url: APIEndpoints.baseURL.userSearch("luke-g86").url, response: UsersSearch.self) { (response, error) in
            if let response = response {
                completion(response.items, nil)
            } else {
                completion([], error)
            }
        }
        print(APIEndpoints.baseURL.userSearch("luke-g86").url)
    }
}


