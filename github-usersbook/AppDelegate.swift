//
//  AppDelegate.swift
//  github-usersbook
//
//  Created by Lukasz on 27/07/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var dataController = DataController(modelName: "github-userbook")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dataController.load()
        
        let splitViewController = window?.rootViewController as! UISplitViewController
        let leftViewController = splitViewController.viewControllers.first as! UINavigationController
   
        let masterViewController = leftViewController.topViewController as! SearchViewController
        let rightViewController = splitViewController.viewControllers.last as! UINavigationController
        let detailsViewController = rightViewController.topViewController as!
        DetailsViewController
        
        detailsViewController.navigationItem.leftItemsSupplementBackButton = true
        detailsViewController.navigationItem.leftBarButtonItem =
            splitViewController.displayModeButtonItem

        masterViewController.dataController = dataController
        
        splitViewController.preferredDisplayMode = .allVisible
      
        splitViewController.preferredPrimaryColumnWidthFraction = 0.4
        splitViewController.maximumPrimaryColumnWidth = splitViewController.view.bounds.size.width;
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }
    
    func saveContext() {
        try? dataController.viewContext.save()
    }
    
}

