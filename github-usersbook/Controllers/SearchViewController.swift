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
    var fetchedResultsController: NSFetchedResultsController<User>!

    weak var delegate: UserSelectionDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        setupSearchBar()
        setTableView()
        cleaningDataBase()
        
        navigationItem.title = "GitHub users finder"

    }

    
    override func viewWillAppear(_ animated: Bool) {
        setupFetchedResultsController()
        tableView.reloadData()
    }
    
    
    func setTableView() {
        tableView.frame = self.view.frame
        
        tableView.separatorColor = UIColor.clear
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "searchCell")
        tableView.allowsSelection = true
        tableView.refreshControl = refreshControl
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
        searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count > 2 {
            setupFetchedResultsController(searchText)
            tableView.reloadData()
            
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
        setupFetchedResultsController()
        tableView.reloadData()
        print("ended editing")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        tableView.reloadData()
        print("cancel")
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! CustomTableViewCell
        
        cell.userNickname.text = gitHubUser.login
        cell.userAvatar.image = UIImage(named: "user-default")
  
        
        if let avatar = gitHubUser.avatarUrl {
            if let avatarURL = URL(string: avatar) {
                
                APIEndpoints.downloadUsersAvatar(avatarURL: avatarURL) { (data, error) in
                    guard let data = data else {
                        return
                    }
                    let image = UIImage(data: data)
                    cell.userAvatar.image = image
                    cell.setNeedsLayout()
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let vc = (segue.destination as! UINavigationController).topViewController as? DetailsViewController else {
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
            
        @unknown default: fatalError("invalid change type in controller didChange")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller didChange at section")
            
        @unknown default:
            fatalError("unknown coreData controller error")
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

extension SearchViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4) {
            cell.transform = CGAffineTransform.identity
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let animationHandler: ((UIViewControllerTransitionCoordinatorContext) -> Void) = { [weak self] (context) in
            // This block will be called several times during rotation,
            // so the tableView change more smoothly
            self?.tableView.reloadData()
            self?.tableView.frame = self!.view.frame
        }
        
        let completionHandler: ((UIViewControllerTransitionCoordinatorContext) -> Void) = { [weak self] (context) in
            // This block will be called when rotation will be completed
            self?.tableView.reloadData()
        }
        coordinator.animate(alongsideTransition: animationHandler, completion: completionHandler)
    }
}
