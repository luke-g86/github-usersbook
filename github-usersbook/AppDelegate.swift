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
        
        let tabBarController = window?.rootViewController as! UITabBarController
        for child in tabBarController.viewControllers ?? [] {
            if let top = child as? DataControllerClient {
                top.setDataController(stack: dataController)
            }
        }
        
        return true
    }



}

