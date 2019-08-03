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


class DetailsViewController: UIViewController {
    
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userLogin: UILabel!
    
    var fetchedResultsController: NSFetchedResultsController<Details>!
    var dataController: DataController!
    
    
    var selectedUser: User? {
        didSet {
            print("detailsViewController")
            presentData()
        }
    }
    
    

    
    override func viewWillAppear(_ animated: Bool) {
        setupFetchedResultsController()
    }
    
    
    
    func presentData() {
        
        loadViewIfNeeded()
       
        userAvatar.image = UIImage(named: "user-default")
        guard let avatar = self.selectedUser?.avatarUrl else {return}
        userLogin.text = selectedUser?.login
        DispatchQueue.main.async {
            self.downloadAvatar(avatar: avatar)
        }
        
        stackView.customize()
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
    
    
}

extension DetailsViewController: UserSelectionDelegate {
    func userSelected(_ newUser: User) {
        selectedUser = newUser
    }
}

extension DetailsViewController: NSFetchedResultsControllerDelegate {
    
}
