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
        
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
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
        
  
        
        generalContainer.addSubview(reposCard)
        
        //MARK: - Detail view constraints
        
        //MARK: ReposCard container constraints
        
        reposCard.topAnchor.constraint(equalTo: userCardContainerView.bottomAnchor, constant: 24).isActive = true
        
        reposCard.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 36).isActive = true
        reposCard.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -36).isActive = true
        reposCard.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
    }

    
}
