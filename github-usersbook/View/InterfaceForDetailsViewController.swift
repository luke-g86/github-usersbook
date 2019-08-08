//
//  InterfaceForDetailsViewController.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 06/08/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import UIKit

extension DetailsViewController {
    

    
    func createUserCard() {
        
        super.view.addSubview(scrollView)
        
        //MARK: - Scroll layer
        
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // CONSTRAINTS
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // ADDING TO THE SUBVIEW
        
        scrollView.addSubview(generalContainer)
        
        // CONTAINER'S VIEW CONSTRAINTS FOR USERCARD
        
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
        
        
        // ADDING CARD ELEMENTS AND SETTING THEIR APPEARANCE
        
        generalContainer.addSubview(userAvatar)
        generalContainer.addSubview(nicknameLabel)
        generalContainer.addSubview(userCardContainerView)
        generalContainer.addSubview(scoreLabel)
        
        generalContainer.bringSubviewToFront(userAvatar)
        generalContainer.bringSubviewToFront(nicknameLabel)
        
        //MARK: - Elements' constraints
        
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
        print("creating repos card")
//        try? fetchedResultsController.performFetch()
        
 
        
        let size: Int = {
            if repos.count == 0 {
                return 200
            }
            return repos.count * 80
        }()
        
        generalContainer.addSubview(reposCard)
        
        
        //MARK: Section label
        
        sectionName.font = UIFont.preferredFont(forTextStyle: .headline)
        
        //MARK: ReposCard config
     
        reposCard.isUserInteractionEnabled = true
        
        
        
        reposCard.addSubview(sectionName)
        
        sectionName.topAnchor.constraint(equalTo: userCardContainerView.bottomAnchor, constant: 24).isActive = true
        sectionName.leadingAnchor.constraint(equalTo: reposCard.leadingAnchor, constant: 4).isActive = true
        //        sectionName.bo.constraint(equalTo: self.view.trailingAnchor, constant: -36).isActive = true
 
        
        //MARK: ReposCard container constraints
        
        reposCard.topAnchor.constraint(equalTo: sectionName.bottomAnchor, constant: 8).isActive = true
        reposCard.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 36).isActive = true
        reposCard.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -36).isActive = true
        reposCard.heightAnchor.constraint(lessThanOrEqualToConstant: CGFloat(size)).isActive = true
        
        
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: CGFloat(size)).isActive = true
        
        reposCard.setNeedsLayout()
        reposCard.layoutIfNeeded()
        
        
        
        //        let detailsTableView = UITableView()
        
        detailsTableView.frame = CGRect(x: 0, y: 0, width: reposCard.frame.width-24, height: reposCard.frame.height-24)
        detailsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "reposCell")
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        
        //        detailsTableView.translatesAutoresizingMaskIntoConstraints = false
        detailsTableView.backgroundColor = UIColor.red
        
        detailsTableView.reloadData()
    
        //MARK: - Detail view constraint
        
        reposCard.addSubview(detailsTableView)
        reposCard.bringSubviewToFront(detailsTableView)
    
        
        detailsTableView.topAnchor.constraint(equalTo: reposCard.topAnchor, constant: 16).isActive = true
        detailsTableView.leadingAnchor.constraint(equalTo: reposCard.leadingAnchor, constant: 12).isActive = true
        detailsTableView.trailingAnchor.constraint(equalTo: reposCard.trailingAnchor, constant: 12).isActive = true
        
        print(detailsTableView.frame.size)
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
    
}

extension DetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let details = fetchedResultsController.object(at: indexPath)
        let reuseIdentifier = "reposCell"
    
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! UITableViewCell
        cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        
        cell.textLabel?.text = details.name
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)

        cell.detailTextLabel?.text = "⭐️ Number of stars: \(String(describing: details.stargazersCount)) || 📅 Creation date: \(String(describing: details.repoCreationDate)) || 👀 Watchers: \(String(describing: details.watchersCount))"
        
        cell.detailTextLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}



