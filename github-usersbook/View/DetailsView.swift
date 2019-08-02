//
//  DetailsView.swift
//  github-usersbook
//
//  Created by Łukasz Gajewski on 1/8/19.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import UIKit

    
    extension UIStackView {
        func customize(backgroundColor: UIColor = UIColor.lightGray, radiusSize: CGFloat = 0) {
            let subView = UIView(frame: bounds)
            subView.backgroundColor = backgroundColor
            subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            insertSubview(subView, at: 0)
            
            subView.layer.cornerRadius = 15
            subView.layer.masksToBounds = true
            subView.clipsToBounds = true
        }
    }
    

