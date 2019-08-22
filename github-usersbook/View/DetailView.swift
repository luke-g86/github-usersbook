//
//  UserCard.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 20/08/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit


class DetailView: UIView {
    
    var selectedUser: User?
    
    
    var detailsViewController: DetailsViewController!
    var tableViewDelegates: TableViewDelegates?
    
    
    let generalContainer: UIView = {
        let view = ViewsFactory.view(forBackground: UIColor.white, forAutoresizingMaskIntoConstraints: false)
        view.layer.cornerRadius = 0
        view.backgroundColor = UIColor.blue
        return view
    }()
    
    var userAvatar: UIImageView = {
        let imageView = ViewsFactory.imageView(image: nil, forAutoresizingMaskIntoConstraints: false)
        imageView.backgroundColor = UIColor.lightGray
        return imageView }()
    
    var nicknameLabel = ViewsFactory.label(text: "userNickname", color: UIColor.black, numberOfLines: 1, fontSize: 36)
    let userCardContainerView = ViewsFactory.view(forBackground: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), forAutoresizingMaskIntoConstraints: false)
    let scoreLabel = ViewsFactory.label(text: "userScore", color: UIColor.black, numberOfLines: 1, fontSize: 30)
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.red
        return view
    }()
    
    let reposCard = ViewsFactory.view(forBackground: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), forAutoresizingMaskIntoConstraints: false)
    let reposLabel = ViewsFactory.label(text: "Repositories", color: UIColor.darkGray, numberOfLines: 1, fontSize: 24)
    let sectionName = ViewsFactory.label(text: "User repositories", color: UIColor.darkGray, numberOfLines: 1, fontSize: 18)
    let detailsTableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = CGRect.zero
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reposCell")
        return tableView
    }()
    
    
    init(selectedUser:User, frame: CGRect, detailsViewController: DetailsViewController) {
        super.init(frame: frame)
        self.selectedUser = selectedUser
        self.detailsViewController = detailsViewController
        print("detail view init")
        tableViewDelegates = TableViewDelegates(detailsViewController: detailsViewController)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createUserCard() {
        
        addSubview(scrollView)
        
        scrollView.delegate = detailsViewController
        
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        
        //MARK: Constraints - ScrollView
        
        scrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        
        scrollView.addSubview(generalContainer)
        
        generalContainer.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        generalContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        generalContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        
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
        
        
        //MARK: Constraints - UserCards
        
        userCardContainerView.topAnchor.constraint(equalTo: generalContainer.topAnchor, constant: 36 + avatarHeight/2).isActive = true
        userCardContainerView.leadingAnchor.constraint(equalTo: generalContainer.leadingAnchor, constant: 36).isActive = true
        userCardContainerView.trailingAnchor.constraint(equalTo: generalContainer.trailingAnchor, constant: -36).isActive = true
        userCardContainerView.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        //MARK: Constraints - Avatar
        
        userAvatar.topAnchor.constraint(equalTo: userCardContainerView.topAnchor, constant: -(avatarHeight / 2)).isActive = true
        userAvatar.centerXAnchor.constraint(equalTo: userCardContainerView.centerXAnchor, constant: 0).isActive = true
        userAvatar.widthAnchor.constraint(equalToConstant: 120).isActive = true
        userAvatar.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        //MARK: Constraints - Nickname label
        
        nicknameLabel.topAnchor.constraint(equalTo: userAvatar.bottomAnchor, constant: 12).isActive = true
        nicknameLabel.centerXAnchor.constraint(equalTo: userAvatar.centerXAnchor, constant: 0).isActive = true
        nicknameLabel.leadingAnchor.constraint(lessThanOrEqualTo: userCardContainerView.leadingAnchor, constant: 16).isActive = true
        nicknameLabel.trailingAnchor.constraint(lessThanOrEqualTo: userCardContainerView.trailingAnchor, constant: -16).isActive = true
        
        //MARK: Constraints - Score Label
        
        scoreLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 24).isActive = true
        scoreLabel.centerXAnchor.constraint(equalTo: userCardContainerView.centerXAnchor, constant: 0).isActive = true
        
        userCardData()
    }
    
    func userCardData() {
        guard let selectedUser = selectedUser else {
            return
        }
        
        selectedUser.displayed = true
        
//        // setting users avatar if its already downloaded. If not, there's an attempt to download it.
//        
//        if let image = selectedUser.avatar {
//            userAvatar.image = UIImage(data: image)
//        } else {
//            //    guard let avatarUrl = selectedUser.avatarUrl else {return}
//            //    downloadAvatar(avatar: avatarUrl)
//        }
        
        nicknameLabel.text = "🤓 \(selectedUser.login!)"
        scoreLabel.text = "Scoring ✅: \(String(format: "%.1f", selectedUser.score))"
    }
    
    
    func createReposCard(for repos: [UsersRepositories]) {
        
        let size: Int = {
            if repos.count == 0 {
                return 200
            }
            return repos.count * 70
        }()
        
        generalContainer.addSubview(reposCard)
        
        
        
        //MARK: Section label
        
        sectionName.font = UIFont.preferredFont(forTextStyle: .headline)
        
        //MARK: ReposCard config
        
        reposCard.isUserInteractionEnabled = true
        reposCard.addSubview(sectionName)
        
        
        //MARK: Constraints - SectionName
        sectionName.topAnchor.constraint(equalTo: userCardContainerView.bottomAnchor, constant: 24).isActive = true
        sectionName.leadingAnchor.constraint(equalTo: reposCard.leadingAnchor, constant: 4).isActive = true
        
        //MARK: Constraints - ReposContainer
        reposCard.topAnchor.constraint(equalTo: sectionName.bottomAnchor, constant: 8).isActive = true
        reposCard.leadingAnchor.constraint(equalTo: generalContainer.leadingAnchor, constant: 36).isActive = true
        reposCard.trailingAnchor.constraint(equalTo: generalContainer.trailingAnchor, constant: -36).isActive = true
        reposCard.widthAnchor.constraint(equalTo: userCardContainerView.widthAnchor).isActive = true
        reposCard.heightAnchor.constraint(equalToConstant: CGFloat(size) + 10).isActive = true
        
        
        
        reposCard.setNeedsLayout()
        reposCard.layoutIfNeeded()
        
        
        detailsTableView.clipsToBounds = true
        detailsTableView.translatesAutoresizingMaskIntoConstraints = false
        detailsTableView.delegate = tableViewDelegates
        detailsTableView.dataSource = tableViewDelegates
        detailsTableView.reloadData()
        
        
        
        
        //MARK: - Detail view constrains
        
        reposCard.addSubview(detailsTableView)
        reposCard.bringSubviewToFront(detailsTableView)
        
        
        
        //MARK: Constraints - update view size for detailsTableView and reposCard
        detailsTableView.topAnchor.constraint(equalTo: reposCard.topAnchor, constant:8).isActive = true
        detailsTableView.leadingAnchor.constraint(equalTo: reposCard.leadingAnchor, constant: 4).isActive = true
        detailsTableView.trailingAnchor.constraint(equalTo: reposCard.trailingAnchor, constant: -4).isActive = true
        detailsTableView.bottomAnchor.constraint(equalTo: reposCard.bottomAnchor, constant: -4).isActive = true

        
        scrollView.bottomAnchor.constraint(equalTo: reposCard.bottomAnchor, constant: 0).isActive = true
        scrollView.updateConstraints()
        
        
    }
    
    
}
