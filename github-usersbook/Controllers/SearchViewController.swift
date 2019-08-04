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
        setupFetchedResultsController()
        setupSearchBar()
        cleaningDataBase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupFetchedResultsController()
    }
    
    func setupFetchedResultsController(_ searchText: String? = nil) {
        
        // Deleteing cache which sometimes blocks NSPredicate to work
        
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: nil)
        let fetchRequest =  NSFetchRequest<User>(entityName: "User")
        if searchText != nil {
            let predicate = NSPredicate(format:"login CONTAINS[cd] '\(searchText!)'")
            fetchRequest.predicate = predicate
        }
        
        let sortDescriptor = NSSortDescriptor(key: "login", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "users")
        
        fetchedResultsController.delegate = self
        
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError("Fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func cleaningDataBase() {
        
        // delete all entries older then 8 days which do not have saved details
        
        var expirationDate: Date {
            let currentDate = Date()
            return Calendar.current.date(byAdding: .day, value: -8, to: currentDate)!
        }
        
        guard let data = fetchedResultsController.fetchedObjects else { return }
        for object in data {
            // deletion if object has no details, creation date or it is older than full 7 days
            if (object.details?.count == 0) && (object.creationDate ?? expirationDate <= expirationDate) {
                dataController.viewContext.delete(object)
            }
        }
    }
    
}

//MARK: - Search

extension SearchViewController: UISearchBarDelegate {
    
    func setupSearchBar() {
        searchBar.placeholder = "Type at least 3 characters to search"
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        currentSearchTask?.cancel()
        
        if searchText.count > 2 {
            setupFetchedResultsController(searchText)
            tableView.reloadData()
            print("do it")
            print(fetchedResultsController.fetchedObjects?.count)
            print(fetchedResultsController.fetchedObjects?.count == 0)
            if fetchedResultsController.fetchedObjects?.count == 0 {
                let gitHubUser = User(context: dataController.viewContext)
                
                
                _ = APIEndpoints.search(query: searchText) { (data, error) in
                    for user in data {
                        gitHubUser.avatarUrl = user.avatar
                        gitHubUser.creationDate = Date()
                        gitHubUser.login = user.login
                        gitHubUser.score = user.score ?? 0
                        gitHubUser.reposUrl = user.reposUrl
                    }
                    try? self.dataController.viewContext.save()
                    self.tableView.reloadData()
                }
                
                tableView.reloadData()
                
            }
        }
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        tableView.reloadData()
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        tableView.reloadData()
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let vc = (segue.destination as! UINavigationController).topViewController as? DetailsViewController else {
                print("pushing to the next VC error")
                return }
            if let indexPath = tableView.indexPathForSelectedRow {
                
                vc.delegate = self
                vc.userSelected(fetchedResultsController.object(at: indexPath))
                vc.dataController = dataController
            }
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
