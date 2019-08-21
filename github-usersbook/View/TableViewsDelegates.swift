//
//  TableViewsDelegates.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 21/08/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit

public class TableViewDelegates: NSObject, UITableViewDataSource,UITableViewDelegate {
    
    private let detailsViewController: DetailsViewController
    
    init(detailsViewController: DetailsViewController){
        self.detailsViewController = detailsViewController
        try? detailsViewController.fetchedResultsController.fetchRequest
        
        super.init()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return detailsViewController.fetchedResultsController.sections?.count ?? 1
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailsViewController.fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let details = detailsViewController.fetchedResultsController.object(at: indexPath)
        let reuseIdentifier = "reposCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! UITableViewCell
        cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = "test"
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        cell.detailTextLabel?.text = "🤖 \(String(describing: details.language ?? "none")) ⭐️ Number of stars: \(String(describing: details.stargazersCount))"
        cell.detailTextLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
