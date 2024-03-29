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
    
    
    var selection: Bool = false
    let fixedRowSize: CGFloat = 70
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<User>!
    var searchViewModel: SearchViewModel!
    var fetchedUsers: [Users]?
    var user: User!
    var fetchingData: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        setupSearchBar()
        setTableView()
        cleaningDatabase()
        splitViewController?.delegate = self
        navigationItem.title = "GitHub users finder"
        
        searchViewModel = SearchViewModel(searchingUser: nil, delegate: self)
        
//        let tapRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
//        tapRecognizer.cancelsTouchesInView = false
//        view.addGestureRecognizer(tapRecognizer)
    
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupFetchedResultsController()
        cleaningDatabase()
        tableView.reloadData()
        settingsForDevice()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkInternetConnection()
    }
    
    
    //MARK: - Devices states
    func settingsForDevice() {
        if UIDevice.current.orientation.isLandscape || UIDevice.current.userInterfaceIdiom == .pad && !selection {
            perform(#selector(selectTableRow), with: nil, afterDelay: 1.0)
        }
    }
    func checkInternetConnection() {
        if !Reachability.isConnectedWithInternet() {
            alert("No internet connection", "It seems that you're not connected to the network. Please note, that functionality of the app will be limited.")
        }
        
    }
    
    
    //MARK: - Setting objects and UI behavior 
    func setTableView() {
        tableView.frame = self.view.frame
        tableView.separatorColor = UIColor.clear
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "searchCell")
        tableView.allowsSelection = true
        tableView.refreshControl = refreshControl
        tableView.prefetchDataSource = self
        
        tableView.keyboardDismissMode = .onDrag
    }
    
    //MARK: TableView row selection
    @objc func selectTableRow() {
        if !tableView.visibleCells.isEmpty {
            let indexPath = IndexPath(row: 0, section: 0)
            
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            _ = tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
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
        
        // Performing delay between searches. If uers is typing previous request is being terminated.
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
        perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.75)
    }
    
    @objc func reload(_ searchBar: UISearchBar) {
        
        // No further verification on the endpoint in APIEndpoint class as the GitHub API does not accept logins with white spaces.
        
        guard let txt = searchBar.text else {return}
        let searchQuery = txt.filter{!$0.isWhitespace}
        
        if searchQuery.count > 2 {
            
            search(searchQuery)
            
            //            if fetchedResultsController.fetchedObjects?.count == 0 {
            searchViewModel.searchingUser = searchQuery
            searchViewModel.fetchSearchedUsers()
            //            }
        }
    }
    
    func search(_ searchedLogin: String) {
        
        let fetchRequest =  NSFetchRequest<User>(entityName: "User")
        let predicate = NSPredicate(format:"login CONTAINS[cd] %@", searchedLogin)
        fetchRequest.predicate = predicate
        let sortDescriptorLogin = NSSortDescriptor(key: "login", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptorLogin]
        fetchRequest.returnsDistinctResults = true
        
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "users")
            
            try fetchedResultsController.performFetch()
            
        } catch {
            print(error.localizedDescription)
        }
       
        tableView.reloadData()
    }
    
    //MARK: - Network
    
    func syncData(_ data: [Users]) {
        
        let backgroundContext = dataController.persistanceContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext.undoManager = nil
        
        let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        backgroundContext.performAndWait {
            let login = data.map {$0.login}.compactMap{$0}
            matchingRequest.predicate = NSPredicate(format: "login ==[c] %@", argumentArray: [login])
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let batchDeleteResult = try backgroundContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs], into: [dataController.viewContext])
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            for user in data {
                guard let gitHubUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: backgroundContext) as? User else {
                    print("error: failed to create new user")
                    return
                }
                gitHubUser.avatarUrl = user.avatar
                gitHubUser.creationDate = Date()
                gitHubUser.login = user.login
                gitHubUser.score = user.score ?? 0
                gitHubUser.reposUrl = user.reposUrl
                
                guard let avatarURL = gitHubUser.avatarUrl else {return}
                if let url = URL(string: avatarURL) {
                    
                    APIEndpoints.downloadUsersAvatar(avatarURL: url) {
                        (data, error) in
                        
                        guard let data = data else {
                            return
                        }
                        gitHubUser.avatar = data
                    }
                    
                }
                
                if backgroundContext.hasChanges {
                    do {
                        try backgroundContext.save()
                    } catch {
                        print("error while saving: \(error.localizedDescription)")
                    }
                    backgroundContext.reset()
                    tableView.reloadData()
                }
                
            }
        }
    }
    
    func fetchedDataProcessor(_ data: [Users]) {
        
        print("data count: \(data.count)")
                let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
//                dataController.viewContext.performAndWait {
                    let login = data.map {$0.login}.compactMap{$0}
                    print("map from login: \(login)")
                    matchingRequest.predicate = NSPredicate(format: "login CONTAINS[cdw] %@", argumentArray: [login])
        
                    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingRequest)
                    batchDeleteRequest.resultType = .resultTypeObjectIDs
        
                    do {
                        let batchDeleteResult = try dataController.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                        
                        
                        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: batchDeleteResult?.result as! [NSManagedObjectID]]
                        
                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [dataController.viewContext])
                        
                        print("deleted \(changes)")
                        
                        
                        dataController.viewContext.reset()
                        
                        try self.fetchedResultsController.performFetch()
                        tableView.reloadData()
                        
                  
                        
                      
        
//                        if let deletionChanges: [AnyHashable: Any] = [NSDeletedObjectsKey: batchDeleteResult?.result as? [NSManagedObjectID]] {
//
//                            print("deletion changes \(deletionChanges)")
//                         NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletionChanges, into: [dataController.viewContext])
//
////                            if dataController.viewContext.hasChanges {
////                                try dataController.viewContext.save()
////                            }
//                            tableView.reloadData()
//                            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs], into: [dataController.viewContext])
                        
                    } catch {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
        

            
            DispatchQueue.main.async {
                
                for user in data {
                    
                    //            let login = data.map {$0.login}.compactMap{$0}
                    //            matchingRequest.predicate = NSPredicate(format: "login in %@", argumentArray: [login])
                    //            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingRequest)
                    //            batchDeleteRequest.resultType = .resultTypeObjectIDs
                    
                    let gitHubUser = User(context: self.dataController.viewContext)
                    gitHubUser.avatarUrl = user.avatar
                    gitHubUser.creationDate = Date()
                    gitHubUser.login = user.login
                    gitHubUser.score = user.score ?? 0
                    gitHubUser.reposUrl = user.reposUrl
                    
                    guard let avatarURL = gitHubUser.avatarUrl else {return}
                    if let url = URL(string: avatarURL) {
                        
                        APIEndpoints.downloadUsersAvatar(avatarURL: url) {
                            (data, error) in
                            
                            guard let data = data else {
                                return
                            }
                            gitHubUser.avatar = data
                        }
                    }
                    
                }
                try? self.dataController.viewContext.save()
            }
        }
    
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        resignFirstResponder()
        tableView.reloadData()
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        resignFirstResponder()
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        resignFirstResponder()
        searchBar.showsCancelButton = false
        cleaningDatabase()
        setupFetchedResultsController()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        cleaningDatabase()
        setupFetchedResultsController()
        tableView.reloadData()
        searchViewModel.searchCompleted = true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

//MARK: - tableView

extension SearchViewController: UITableViewDataSourcePrefetching {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let gitHubUser = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! CustomTableViewCell
        
        
        if isLoadingCell(for: indexPath){
            fetchingData = true
            cell.userNickname.text = " "
            cell.userAvatar.image = UIImage(named: "user-default")
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            
        } else {
            fetchingData = false
            cell.userNickname.text = gitHubUser.login
            cell.userAvatar.image = UIImage(named: "user-default")
            cell.activityIndicator.stopAnimating()
        }
        
        cell.activityIndicator.stopAnimating()
        
        cell.userNickname.text = gitHubUser.login
        cell.userAvatar.image = UIImage(named: "user-default")
        
        //MARK: Downloading avatar
        if let avatar = gitHubUser.avatar {
            cell.userAvatar.image = UIImage(data: avatar)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetails", sender: nil)
        searchViewModel.searchCompleted = true
        selection = true
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return fixedRowSize
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell(for:)) {
            searchViewModel.fetchSearchedUsers()
        }
    }
    
    //MARK: TableViewInfiniteScrolling
    
    func visibleTableViewIndex(indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        print(indexPathsForVisibleRows)
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
        
        guard let data = fetchedResultsController.fetchedObjects else {
            print("no fetched objects")
            return false
        }
        return indexPath.row >= data.count - 2
        
        //        return indexPath.row >= (fetchedResultsController.fetchedObjects?.count ?? 0) - 2
        //            return indexPath.row >= searchViewModel.itemsDownloadedCount - 2
    }
    
    //MARK: Animation
    
    //    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    //        UIView.animate(withDuration: 0.4) {
    //            cell.transform = CGAffineTransform.identity
    //        }
    //    }
    
    
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
    
    
    //MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let vc = (segue.destination as! UINavigationController).topViewController as? DetailsViewController {
                
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let user = self.fetchedResultsController.object(at: indexPath)
                    
                    vc.dataController = dataController
                    vc.selectedUser = user
                }
                
                vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                vc.navigationItem.leftItemsSupplementBackButton = true
                
            }
        }
    }
    
    //MARK: Alert
    
    func alert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - CoreData

extension SearchViewController: NSFetchedResultsControllerDelegate {
    
    func setupFetchedResultsController(_ searchText: String? = nil) {
        
        // Deleteing cache which sometimes blocks NSPredicate to work
        
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: nil)
        let fetchRequest =  NSFetchRequest<User>(entityName: "User")
        
        
        //"login CONTAINS[cd] '\(searchText!)'"
        
        let sortDescriptorLogin = NSSortDescriptor(key: "login", ascending: false)
        let sortDescriptorDate = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorLogin, sortDescriptorDate]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "users")
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError("Fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func cleaningDatabase() {
        
        // delete all entries older then 8 days which do not have saved details
        
        var expirationDate: Date {
            let currentDate = Date()
            return Calendar.current.date(byAdding: .day, value: -8, to: currentDate)!
        }
        
        guard let data = fetchedResultsController.fetchedObjects else { return }
        for object in data {
            // deletion if object has no details, creation date or it is older than full 7 days
            if object.details == nil || object.creationDate ?? expirationDate <= expirationDate {
                dataController.viewContext.delete(object)
            }
        }
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

//MARK: Setting master view controller as first

extension SearchViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}


//MARK: - Protocols

extension SearchViewController: SearchViewModelDelegate {
    func fetchedUsers(with users: [Users]?) {
        guard let users = users else { return }
        
        //        if fetchedResultsController.fetchedObjects?.count == 0 {
        fetchedDataProcessor(users)
        //        } else {
        //            syncData(users)
        //        }
    }
    
    
    
    func fetchSucceeded(with newIndexPathsForTableView: [IndexPath]?) {
        
        guard let newIndexPathsForTableViewToReload = newIndexPathsForTableView else {
            tableView.reloadData()
            return
        }
        
        let indexToReload = visibleTableViewIndex(indexPaths: newIndexPathsForTableViewToReload)
        tableView.reloadRows(at: indexToReload, with: .fade)
        
    }
    
    func fetchFailed(error reason: String) {
        print(reason)
    }
    
    
    
    
}


