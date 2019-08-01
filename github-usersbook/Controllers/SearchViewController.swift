//
//  ViewController.swift
//  github-usersbook
//
//  Created by Lukasz on 27/07/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import CoreData


class SearchViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var dataController: DataController!
    var users = [Users]()
    var currentSearchTask: URLSessionTask?
 
    
    weak var delegate: UserSelectionDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
}


extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchTask?.cancel()
        currentSearchTask = APIEndpoints.search(query: searchText) { (users, error) in
            
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
}


extension SearchViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row]
    
        delegate?.userSelected(selectedUser)
        
        if let detailsViewController = delegate as? DetailsViewController, let detailNavigationController = detailsViewController.navigationController {
    splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
            
        }
    }
    
}

extension SearchViewController: DataControllerClient {
    func setDataController(stack: DataController) {
        self.dataController = stack
    }
}

extension SearchViewController: UserSelectionDelegate {
    func userSelected(_ newUser: Users) {
    }
}
