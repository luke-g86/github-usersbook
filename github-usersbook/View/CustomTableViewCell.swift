//
//  CustomTableViewCell.swift
//  github-usersbook
//
//  Created by Łukasz Gajewski on 1/8/19.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import UIKit

class CustomTableViewCell: UITableViewCell {
    
    lazy var cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    lazy var userAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var userNickname: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        return label
    }()
    
    
    override func layoutSubviews() {
        contentView.backgroundColor = UIColor.clear
        cellView.layer.cornerRadius = 5
        userAvatar.layer.cornerRadius = 0
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        self.contentView.addSubview(cellView)
        cellView.addSubview(userAvatar)
        cellView.addSubview(userNickname)
        
        addLayoutContraints()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addLayoutContraints() {
        cellView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        cellView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
//        cellView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        cellView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        cellView.widthAnchor.constraint(equalToConstant: 100).isActive = true
//        cellView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 5).isActive = true
        
        userAvatar.centerYAnchor.constraint(equalTo: self.cellView.centerYAnchor).isActive = true
        userAvatar.leadingAnchor.constraint(equalTo: self.cellView.leadingAnchor, constant: 10).isActive = true
        userAvatar.widthAnchor.constraint(equalToConstant: 25).isActive = true
        userAvatar.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        userNickname.topAnchor.constraint(equalTo: self.userAvatar.topAnchor, constant: 2).isActive = true
        userNickname.leadingAnchor.constraint(equalTo: self.userNickname.trailingAnchor, constant: 2).isActive = true
        userNickname.trailingAnchor.constraint(equalTo: self.cellView.trailingAnchor, constant: 0).isActive = true
    }
}
