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
    var fetchedResultsController: NSFetchedResultsController<User>!
    
    weak var delegate: UserSelectionDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.tableView.rowHeight = 50
        //        self.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "searchCell")
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupFetchedResultsController()
    }
    
    func setupFetchedResultsController() {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    
        let sortDescriptor = NSSortDescriptor(key: "login", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
            print(fetchRequest)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "users")
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError("Fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
}

//MARK: - Search

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        currentSearchTask?.cancel()

        
        if !searchText.isEmpty {
            
//            setupFetchedResultsController(searchText)
            tableView.reloadData()
            
            print(fetchedResultsController.fetchedObjects?.count)
            
            
            
//            guard let fetchedData = fetchedResultsController.fetchedObjects else { return }
//            let gitHubUser = User(context: dataController.viewContext)
//
//            let result = fetchedData.filter{$0.login?.replacingOccurrences(of: " ", with: "").lowercased() == searchText.replacingOccurrences(of: " ", with: "").lowercased()}
//            print("results: \(result)")
//
//
//
//            if result.isEmpty {
//
//                currentSearchTask = APIEndpoints.search(query: searchText) { (users, error) in
//
//                    for user in users {
//                        gitHubUser.creationDate = Date()
//                        gitHubUser.avatarUrl = user.avatar
//                        gitHubUser.login = user.login
//                        gitHubUser.reposUrl = user.reposUrl
//                        gitHubUser.score = user.score ?? 0
//                    }
//
//                    do {
//                        try self.dataController.viewContext.save()
//                        print("saving")
//                    } catch {
//                        print("saving error: \(error.localizedDescription)")
//                    }
//
//                    try? self.fetchedResultsController.performFetch()
//                }
//                print("number of objects: \(fetchedResultsController.fetchedObjects?.count)")
//
//                self.tableView.reloadData()
//
//            }
            self.tableView.reloadData()
        }
    }


                
                //        let gitHubUser = User(context: dataController.viewContext)
                //
                //        currentSearchTask?.cancel()
                //        currentSearchTask = APIEndpoints.search(query: searchText) { (users, error) in
                //
                //            for user in users {
                //                gitHubUser.creationDate = Date()
                //                gitHubUser.avatarUrl = user.avatar
                //                gitHubUser.login = user.login
                //                gitHubUser.reposUrl = user.reposUrl
                //                gitHubUser.score = user.score ?? 0
                //            }
                //
                //            do {
                //                try self.dataController.viewContext.save()
                //                print("saving")
                //            } catch {
                //                print("saving error: \(error.localizedDescription)")
                //            }
                //
                //            try? self.fetchedResultsController.performFetch()
                
                

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
    
    //MARK: - tableView data source
    
    extension SearchViewController {
        override func numberOfSections(in tableView: UITableView) -> Int {
            return fetchedResultsController.sections?.count ?? 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let gitHubUser = fetchedResultsController.object(at: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! UITableViewCell
            
            
            
            cell.textLabel?.text = gitHubUser.login
            cell.imageView?.image = UIImage(named: "user-default")
            
            if let avatar = gitHubUser.avatarUrl {
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
            let selectedUser = fetchedResultsController.object(at: indexPath)
            
            
            delegate?.userSelected(selectedUser)
            
            if let detailsViewController = delegate as? DetailsViewController, let detailNavigationController = detailsViewController.navigationController {
                splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
                
            }
        }
        
    }
    
    //MAKR: Dependency injection for coreData
    
    extension SearchViewController: DataControllerClient, NSFetchedResultsControllerDelegate {
        func setDataController(stack: DataController) {
            self.dataController = stack
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            
            switch type {
            case .insert: tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete: tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update: tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move: tableView.moveRow(at: indexPath!, to: newIndexPath!)
            
            default: fatalError("invalid change type in controller didChange")
            }
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
            let indexSet = IndexSet(integer: sectionIndex)
            
            switch type {
            case .insert: tableView.insertSections(indexSet, with: .fade)
            case .delete: tableView.deleteSections(indexSet, with: .fade)
            case .update, .move:
                fatalError("Invalid change type in controller didChange at section")
                
            }
        }
        
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.beginUpdates()
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.endUpdates()
        }
        
        
    }
    
    extension SearchViewController: UserSelectionDelegate {
        func userSelected(_ newUser: User) {
        }
        
        
}
