//
//  ViewsFactory.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 06/08/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import UIKit

public class ViewsFactory {
    
    public static func view(forBackground backgroundColor: UIColor, forAutoresizingMaskIntoConstraints translatesAutoresizingMaskIntoConstraints: Bool) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        view.backgroundColor = backgroundColor
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 8, height: 8)
        view.layer.shadowRadius = 15
        view.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.layer.borderWidth = 0.3
        view.layer.cornerRadius = 15
        view.clipsToBounds = false
        view.isUserInteractionEnabled = false
    
        
        return view
    }
    
    public static func label(text: String, color: UIColor, numberOfLines: Int, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textAlignment = .left
        label.textColor = color
        label.numberOfLines = numberOfLines
        label.font = UIFont(name: "HelveticaNeue-Light", size: fontSize)
        
        
        return label
    }
    
    public static func imageView(image: UIImage? = nil, forAutoresizingMaskIntoConstraints translatesAutoresizingMaskIntoConstraints: Bool) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }
}
