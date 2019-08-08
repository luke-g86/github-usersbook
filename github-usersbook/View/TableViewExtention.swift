//
//  TableViewExtention.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 08/08/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import UIKit

public extension UITableView {
    
    public func beginRefreshing() {
        // Make sure that a refresh control to be shown was actually set on the view
        // controller and the it is not already animating. Otherwise there's nothing
        // to refresh.
        guard let refreshControl = refreshControl, !refreshControl.isRefreshing else {
            return
        }
        // Start the refresh animation
        refreshControl.beginRefreshing()
        // Make the refresh control send action to all targets as if a user executed
        // a pull to refresh manually
        refreshControl.sendActions(for: .valueChanged)
        // Apply some offset so that the refresh control can actually be seen
        let contentOffset = CGPoint(x: 0, y: -refreshControl.frame.height)
        setContentOffset(contentOffset, animated: true)
    }
    public func endRefreshing() {
        refreshControl?.endRefreshing()
    }
}
    

