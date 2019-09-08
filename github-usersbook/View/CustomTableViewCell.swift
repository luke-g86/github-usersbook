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
        view.backgroundColor = #colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    lazy var userAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
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
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        indicator.color = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    override func layoutSubviews() {
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        cellView.layer.cornerRadius = 5
        userAvatar.layer.cornerRadius = 10
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        self.contentView.addSubview(cellView)
        cellView.addSubview(userAvatar)
        cellView.addSubview(userNickname)
        cellView.addSubview(activityIndicator)
        addLayoutContraints()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func addLayoutContraints() {
        cellView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        cellView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        cellView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 32).isActive = true
        cellView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -32).isActive = true

        userAvatar.centerYAnchor.constraint(equalTo: self.cellView.centerYAnchor).isActive = true
        userAvatar.leadingAnchor.constraint(equalTo: self.cellView.leadingAnchor, constant: 5).isActive = true
        userAvatar.widthAnchor.constraint(equalToConstant: 50).isActive = true
        userAvatar.heightAnchor.constraint(equalToConstant: 50).isActive = true

        userNickname.centerYAnchor.constraint(equalTo: self.userAvatar.centerYAnchor, constant: 0).isActive = true
        userNickname.leadingAnchor.constraint(equalTo: self.userAvatar.trailingAnchor, constant: 20).isActive = true
        userNickname.trailingAnchor.constraint(equalTo: self.cellView.trailingAnchor, constant: -20).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
    }
}
