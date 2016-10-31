//
//  AppDelegate.swift
//  SubTitles
//
//  Created by María Camila Angel on 4/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let primaryColor = UIColor(red:0.26, green:0.68, blue:0.71, alpha:1.0)
        let secondaryColor = UIColor(red:0.60, green:0.51, blue:0.64, alpha:1.0)
        
        UIApplication.shared.statusBarStyle = .lightContent
        // Set navigation bar tint / background colour
        //UINavigationBar.appearance().barTintColor = primaryColor
        //Set navigation bar Back button tint colour
        UINavigationBar.appearance().tintColor = UIColor.white
        // Set Navigation bar Title colour
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        UITabBar.appearance().tintColor = primaryColor
        
        //UIButton.appearance().backgroundColor = secondaryColor
        //UIButton.appearance().tintColor = UIColor.whiteColor()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

