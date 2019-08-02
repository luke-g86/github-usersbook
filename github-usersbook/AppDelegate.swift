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
        
        // Reference to the persistance
        
        /*
         uard let splitViewController = window?.rootViewController as? UISplitViewController,
         let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
         let masterViewController = leftNavController.topViewController as? MasterViewController,
         let detailViewController = splitViewController.viewControllers.last as? DetailViewController
         else { fatalError() }
         
         let firstMonster = masterViewController.monsters.first
         detailViewController.monster = firstMonster
         
         return true
         */
        
        
        let splitViewController = window?.rootViewController as! UISplitViewController
        let leftViewController = splitViewController.viewControllers.first as! UINavigationController
        //        for child in leftViewController.viewControllers ?? [] {
        //            if let top = child as? DataControllerClient {
        //                top.setDataController(stack: dataController)
        //            }
        //        }
        let masterViewController = leftViewController.topViewController as! SearchViewController
        let rightViewController = splitViewController.viewControllers.last as! UINavigationController
        let detailsViewController = rightViewController.topViewController as!
        DetailsViewController
        
        detailsViewController.navigationItem.leftItemsSupplementBackButton = true
        detailsViewController.navigationItem.leftBarButtonItem =
            splitViewController.displayModeButtonItem

        masterViewController.dataController = dataController
        
        
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

