//
//  ViewController.swift
//  github-usersbook
//
//  Created by Lukasz on 27/07/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var users = [Users]()
    
    
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
    
    
    func getUser(completion: @escaping ([Users]?, Error?) -> Void) {
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

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell")!
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.login
        cell.imageView?.image = UIImage(named: "user-default")
        
        if let avatar = user.avatar {
            if let avatarURL = URL(string: avatar) {
                
                APIEndpoints.downloadUsersAvatar(avatarURL: avatarURL) { (data, error) in
                    guard let data = data else {
                        return
                    }
                    let image = UIImage(data: data)
                    cell.imageView?.image = image
                    cell.setNeedsLayout()
                }
            }
        }
        return cell
    }
    
    
}
