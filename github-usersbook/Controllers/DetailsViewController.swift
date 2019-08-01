//
//  DetailsViewController.swift
//  github-usersbook
//
//  Created by Łukasz Gajewski on 1/8/19.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import UIKit

class DetailsViewController: UIViewController {
    
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userLogin: UILabel!
    
    var selectedUser: Users? {
        didSet {
            
            presentData()
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func presentData() {
        
        loadViewIfNeeded()
        userAvatar.image = UIImage(named: "user-default")
        guard let avatar = self.selectedUser?.avatar else {return}
        userLogin.text = selectedUser?.login
        downloadAvatar(avatar: avatar)
        
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
    
    
}

extension DetailsViewController: UserSelectionDelegate {
    func userSelected(_ newUser: Users) {
        selectedUser = newUser
    }
    
    
}
