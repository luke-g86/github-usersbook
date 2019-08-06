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
    
    
    
    //    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userLogin: UILabel!
    
    
    var fetchedResultsController: NSFetchedResultsController<Details>!
    var dataController: DataController!
    weak var delegate: SearchViewController?
    
    var repos: [UsersRepositories] = []
    
    var selectedUser: User? {
        didSet {
            
            presentData()
        }
    }
    
    //MARK: UI View objects
    
    let generalContainer = ViewsFactory.view(forBackground: UIColor.white, forAutoresizingMaskIntoConstraints: false)
    var userAvatar = ViewsFactory.imageView(image: nil, forAutoresizingMaskIntoConstraints: false)
    var nicknameLabel = ViewsFactory.label(text: "userNickname", color: UIColor.black, numberOfLines: 1, fontSize: 36)
    let userCardContainerView = ViewsFactory.view(forBackground: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), forAutoresizingMaskIntoConstraints: false)
    let scoreLabel = ViewsFactory.label(text: "userScore", color: UIColor.black, numberOfLines: 1, fontSize: 30)
    let reposCard = ViewsFactory.view(forBackground: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), forAutoresizingMaskIntoConstraints: false)
    let reposLabel = ViewsFactory.label(text: "Repositories", color: UIColor.darkGray, numberOfLines: 1, fontSize: 24)
    
    
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        setupFetchedResultsController()
        scrollView.delegate = self
        
    }
    
    
    func presentData() {
        
        loadViewIfNeeded()
        self.navigationItem.title = "User details"
        
        createUserCard()
        createReposCard()
        
        
        userAvatar.image = UIImage(named: "user-default")
        guard let selectedUser = selectedUser else {
            print("No user data")
            return
        }
        let avatar = selectedUser.avatarUrl
        nicknameLabel.text = "🤓 \(selectedUser.login!)"
        scoreLabel.text = "Scoring ✅: \(String(format: "%.1f", selectedUser.score))"
        DispatchQueue.main.async {
            self.downloadAvatar(avatar: avatar!)
            
        }
        getRepoDetails(username: selectedUser.login!)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
    }
    
    func downloadAvatar(avatar: String) {
        if let avatarURL = URL(string: avatar) {
            DispatchQueue.main.async {
                APIEndpoints.downloadUsersAvatar(avatarURL: avatarURL) {
                    (data, error) in
                    
                    guard let data = data else {
                        return
                    }
                    self.userAvatar.image = UIImage(data: data)
                    
                }
            }
        }
    }
    
    func getRepoDetails(username: String) {
        APIEndpoints.getDataFromGithub(url: APIEndpoints.baseURL.userRepos(username).url, response: [UsersRepositories].self) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data else {
                    print(error?.localizedDescription)
                    return
                }
                self.repos = data
                let repositories = Details(context: self.dataController.viewContext)
                for item in data {
                    repositories.creationDate = Date()
                    repositories.repoCreationDate = item.createdAt
                    repositories.language = item.language
                    repositories.name = item.name
                    repositories.repoDescription = item.description
                    repositories.stargazersCount =
                    repositories.watchersCount = item.watchersCount
                    
                }
            }
        }
    }
    
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Details> = Details.fetchRequest()
        guard let selectedUser = selectedUser else {return}
        let predicate = NSPredicate(format: "user == %@", selectedUser)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(selectedUser)-details")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
}

extension DetailsViewController: UserSelectionDelegate {
    func userSelected(_ newUser: User) {
        selectedUser = newUser
    }
}

extension DetailsViewController: NSFetchedResultsControllerDelegate {
    
}
