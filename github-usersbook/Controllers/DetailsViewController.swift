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
    
    //MARK: - UI View objects
    
//    let generalContainer = ViewsFactory.view(forBackground: UIColor.white, forAutoresizingMaskIntoConstraints: false)
//    var userAvatar = ViewsFactory.imageView(image: nil, forAutoresizingMaskIntoConstraints: false)
//    var nicknameLabel = ViewsFactory.label(text: "userNickname", color: UIColor.black, numberOfLines: 1, fontSize: 36)
//    let userCardContainerView = ViewsFactory.view(forBackground: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), forAutoresizingMaskIntoConstraints: false)
//    let scoreLabel = ViewsFactory.label(text: "userScore", color: UIColor.black, numberOfLines: 1, fontSize: 30)
//    let reposCard = ViewsFactory.view(forBackground: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), forAutoresizingMaskIntoConstraints: false)
//    let reposLabel = ViewsFactory.label(text: "Repositories", color: UIColor.darkGray, numberOfLines: 1, fontSize: 24)
//    let sectionName = ViewsFactory.label(text: "User repositories", color: UIColor.darkGray, numberOfLines: 1, fontSize: 18)
//    let detailsTableView = UITableView()
    
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    
//    let scrollView: UIScrollView = {
//        let view = UIScrollView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    
    var detailView: DetailView! { return self.view as? DetailView }
    
    
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
    
    
    
    
    //MARK: - View states
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupFetchedResultsController()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        fetchedResultsController = nil
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
        view = DetailView(selectedUser: selectedUser, frame: UIScreen.main.bounds)
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
                
//                try? self.fetchedResultsController.fetchRequest
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
            _ = APIEndpoints.getDataFromGithub(url: APIEndpoints.baseURL.userRepos(username).url, response: [UsersRepositories].self) { (data, error) in
                guard let data = data else {
                    print(error?.localizedDescription ?? "unknown error")
                    return
                }
                self.repos = data
                //MARK: Defining ManagedObject
                for item in data {
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
    
}


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


extension DetailsViewController: UISplitViewControllerDelegate {
    
}
