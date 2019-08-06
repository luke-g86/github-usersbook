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

    
    var selectedUser: User? {
        didSet {
            
            presentData()
        }
    }

    var userAvatar = ViewsFactory.imageView(image: nil, forAutoresizingMaskIntoConstraints: false)
    var nicknameLabel = ViewsFactory.label(text: "userNickname", color: UIColor.black, numberOfLines: 1, fontSize: 36)
    let userCardContainerView = ViewsFactory.view(forBackground: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), forAutoresizingMaskIntoConstraints: false)
   let scoreLabel = ViewsFactory.label(text: "userScore", color: UIColor.black, numberOfLines: 1, fontSize: 30)
    
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
        guard let avatar = self.selectedUser?.avatarUrl else {return}
        nicknameLabel.text = "🤓 \(selectedUser?.login ?? " ")"
        scoreLabel.text = "Scoring ✅: \(String(format: "%.1f", selectedUser?.score ?? 0))"
        DispatchQueue.main.async {
            self.downloadAvatar(avatar: avatar)
        }
       
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
    
    func createUserCard() {
        
        super.view.addSubview(scrollView)
        
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
    
        let generalContainer = ViewsFactory.view(forBackground: UIColor.white, forAutoresizingMaskIntoConstraints: false)
//        generalContainer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
       
        
        

        scrollView.addSubview(generalContainer)
        
        generalContainer.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        generalContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        generalContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        generalContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        
        // AVATAR
        
        userAvatar.clipsToBounds = true
        userAvatar.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        let avatarHeight = userAvatar.frame.height
        userAvatar.layer.cornerRadius = avatarHeight / 2
        userAvatar.layer.borderWidth = 0.5
        userAvatar.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        userAvatar.layer.masksToBounds = true
        
        // NICKNAME LABEL
        
        nicknameLabel.textAlignment = .center
        nicknameLabel.adjustsFontSizeToFitWidth = true
        
        
        // SCORE LABEL
        
        scoreLabel.textAlignment = .left
        
        // CONTAINER VIEW FOR USERCARD

        
        // ADDING VIEWS AND SETTING THEIR APPEARANCE
        
     
        generalContainer.addSubview(userAvatar)
        generalContainer.addSubview(nicknameLabel)
        generalContainer.addSubview(userCardContainerView)
        generalContainer.addSubview(scoreLabel)
//        view.addSubview(userAvatar)
//        view.addSubview(nicknameLabel)
//        view.addSubview(userCardContainerView)
//        view.addSubview(scoreLabel)
//        scrollView.addSubview(userAvatar)
//        scrollView.addSubview(nicknameLabel)
//        scrollView.addSubview(userCardContainerView)
//        scrollView.addSubview(scoreLabel)
        
        generalContainer.bringSubviewToFront(userAvatar)
        generalContainer.bringSubviewToFront(nicknameLabel)
        
        //MARK: - Detail view constraints
        
        //MARK: UserCard container constraints
        
        userCardContainerView.topAnchor.constraint(equalTo: generalContainer.topAnchor, constant: 36 + avatarHeight/2).isActive = true
        
        userCardContainerView.leadingAnchor.constraint(equalTo: generalContainer.leadingAnchor, constant: 36).isActive = true
        userCardContainerView.trailingAnchor.constraint(equalTo: generalContainer.trailingAnchor, constant: -36).isActive = true
        
        userCardContainerView.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        //MARK: Avatar constraints
        
        userAvatar.topAnchor.constraint(equalTo: userCardContainerView.topAnchor, constant: -(avatarHeight / 2)).isActive = true
        userAvatar.centerXAnchor.constraint(equalTo: userCardContainerView.centerXAnchor, constant: 0).isActive = true
        
        userAvatar.widthAnchor.constraint(equalToConstant: 120).isActive = true
        userAvatar.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        //MARK: Nickname label constraints
        
        nicknameLabel.topAnchor.constraint(equalTo: userAvatar.bottomAnchor, constant: 12).isActive = true
        nicknameLabel.centerXAnchor.constraint(equalTo: userAvatar.centerXAnchor, constant: 0).isActive = true
        nicknameLabel.leadingAnchor.constraint(lessThanOrEqualTo: userCardContainerView.leadingAnchor, constant: 16).isActive = true
        nicknameLabel.trailingAnchor.constraint(lessThanOrEqualTo: userCardContainerView.trailingAnchor, constant: -16).isActive = true
        
        
        //MARK: Score label constraints
        
        scoreLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 24).isActive = true
        scoreLabel.centerXAnchor.constraint(equalTo: userCardContainerView.centerXAnchor, constant: 0).isActive = true
        
    }
    
    
    
    func createReposCard() {
        
        let reposCard = ViewsFactory.view(forBackground: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), forAutoresizingMaskIntoConstraints: false)
        
        view.addSubview(reposCard)
        
        //MARK: - Detail view constraints
        
        //MARK: ReposCard container constraints
        
        reposCard.topAnchor.constraint(equalTo: userCardContainerView.bottomAnchor, constant: 24).isActive = true
        
        reposCard.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 36).isActive = true
        reposCard.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -36).isActive = true
        reposCard.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
    }

    
}

extension DetailsViewController: UserSelectionDelegate {
    func userSelected(_ newUser: User) {
        selectedUser = newUser
    }
}

extension DetailsViewController: NSFetchedResultsControllerDelegate {
    
}
