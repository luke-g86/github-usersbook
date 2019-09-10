//
//  DetailsViewController.swift
//  github-usersbook
//
//  Created by Łukasz Gajewski on 1/8/19.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import UIKit
import CoreData



class DetailsViewController: UIViewController, UIScrollViewDelegate {

    
    
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    
    weak var detailView: DetailView! { return self.view as? DetailView }
    
    var searchViewModel: SearchViewModel!
    
    var fetchedResultsController: NSFetchedResultsController<Details>!
    var dataController: DataController!
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "github-users-repos")
    var repos: [UsersRepositories] = []
    var selectedUser: User? {
        didSet {
            presentData()
        }
    }
    private var model: SearchViewModel!
  
    

    
    //MARK: - View states
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupFetchedResultsController()
  
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        fetchedResultsController = nil
    }
    
    deinit {
        print("Details View Controller deallocated")
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.updateViewConstraints()
    }
    
    func presentData() {
        
        setupFetchedResultsController()
        loadViewIfNeeded()
        self.navigationItem.title = "User details"
        
    
        
//         setting avatar placeholder
        detailView.userAvatar.image = UIImage(named: "user-default")
        
        // setting users avatar if its already downloaded. If not, there's an attempt to download it.
        
        guard let selectedUser = selectedUser else {return}
        
        if let image = selectedUser.avatar {
            detailView.userAvatar.image = UIImage(data: image)
        } else {
                guard let avatarUrl = selectedUser.avatarUrl else {return}
                downloadAvatar(avatar: avatarUrl)
        }
        
       
       
        
        
        // setting UI for the details view
        settingUI()
        
    }
    
    override func loadView() {
        guard let selectedUser = selectedUser else {return}
        view = DetailView(selectedUser: selectedUser, frame: UIScreen.main.bounds, detailsViewController: self)
   
    }
    
    func settingUI() {
        
        guard let selectedUser = selectedUser else {return}
        
        
        // Getting user's repositories
        getRepoDetails(username: selectedUser.login!)
        
        // Creating his login and scoring card
        detailView.createUserCard()
        
        
        activityIndicatorSetup()
        
        // Creating details view (queue dispatched, waiting for the getRepoDetails to finish network request)
        dispatchGroup.notify(queue: dispatchQueue) {
            DispatchQueue.main.async {
                
                // slide animation
                UIView.animate(withDuration: 0.75, delay: 0.5, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [], animations: {
                    self.detailView.reposCard.center = CGPoint(x: self.detailView.reposCard.center.x, y: self.detailView.reposCard.center.y-UIScreen.main.bounds.height)
                }, completion: nil)
                
                self.detailView.createReposCard(for: self.repos)
                self.detailView.detailsTableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
            }
        }

    }
    
    func activityIndicatorSetup() {
        self.view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: detailView.userCardContainerView.bottomAnchor, constant: 100).isActive = true
        activityIndicator.startAnimating()
    }
    
    // MARK: - Networking
    
    //MARK: Repo details download for specific userName
    
    func prepareDataBaseForFetchingNewData() {
        
        // deleting details
        try? fetchedResultsController.performFetch()
        guard let details = fetchedResultsController.fetchedObjects else {return}
        
        
        if details.count != 0 {
            for detail in details {
                dataController.viewContext.delete(detail)
            }
            try? dataController.viewContext.save()
            dataController.viewContext.refreshAllObjects()
        }
    }
    
    func getRepoDetails(username: String) {

        if Reachability.isConnectedWithInternet() {
            prepareDataBaseForFetchingNewData()

            self.dispatchGroup.enter()
            _ = APIEndpoints.getDataFromGithub(url: APIEndpoints.baseURL.userRepos(username).url, response: [UsersRepositories].self) { response in
                switch response {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let data):
                    self.repos = data
                }
        
                print("fetching data")
                //MARK: Defining ManagedObject
                for item in self.repos {
                    let repositories = Details(context: self.dataController.viewContext)
                    repositories.creationDate = Date()
                    repositories.repoCreationDate = item.createdAt
                    repositories.language = item.language
                    repositories.name = item.name
                    repositories.repoDescription = item.description
                    repositories.stargazersCount = Int32("\(String(describing: item.watchersCount!))") ?? 0
                    repositories.watchersCount = Int32("\(String(describing: item.watchersCount!))") ?? 0
                    repositories.user = self.selectedUser!
                }
                //MARK: Saving data to CoreData
                do {
                    try self.dataController.viewContext.save()

                } catch {
                    print("saving error: \(error.localizedDescription)")
                }
                print("data fetched")
                self.dispatchGroup.leave()
            }
        }
    }
    
    
    // MARK: Avatar download
    
    func downloadAvatar(avatar: String) {
        if let avatarURL = URL(string: avatar) {
            DispatchQueue.main.async {
                APIEndpoints.downloadUsersAvatar(avatarURL: avatarURL) {
                    (data, error) in
                    DispatchQueue.main.async {
                        guard let data = data else {
                            return
                        }
                        self.detailView.userAvatar.image = UIImage(data: data)
                        let gitHubUser = User(context: self.dataController.viewContext)
                        gitHubUser.avatar = data
                        
                        try? self.dataController.viewContext.save()
                    }
                }
            }
        }
    }
    
    // MARK: - CoreData set up
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Details> = Details.fetchRequest()
        guard let selectedUser = selectedUser else {return}
        let predicate = NSPredicate(format: "user == %@", selectedUser)
        fetchRequest.predicate = predicate
        let dateSortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let starsSortDescriptor = NSSortDescriptor(key: "stargazersCount", ascending: false)
        fetchRequest.sortDescriptors = [starsSortDescriptor, dateSortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(selectedUser.creationDate)-details")
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
    
}


//MARK: - TableView delegates



extension DetailsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert: detailView.detailsTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete: detailView.detailsTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update: detailView.detailsTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move: detailView.detailsTableView.moveRow(at: indexPath!, to: newIndexPath!)
            
        @unknown default: fatalError("invalid change type in controller didChange")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert: detailView.detailsTableView.insertSections(indexSet, with: .fade)
        case .delete: detailView.detailsTableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller didChange at section")
            
        @unknown default:
            fatalError("unknown coreData controller error")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        detailView.detailsTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        detailView.detailsTableView.endUpdates()
    }
}

extension DetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let details = fetchedResultsController.object(at: indexPath)
        let reuseIdentifier = "reposCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! UITableViewCell
        cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = details.name
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        cell.detailTextLabel?.text = "🤖 \(String(describing: details.language ?? "none")) ⭐️ Number of stars: \(String(describing: details.stargazersCount))"
        cell.detailTextLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}



    
