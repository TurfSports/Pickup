//
//  AppDelegate.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/18/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Theme.applyTheme()
        
        // Initialize Parse.
        Parse.setApplicationId("vXTZeIEcllE2fqSPJab5OdZkCbB9TmfW9DIutXJn",
            clientKey: "xUjfmNs7umcLNLUdINYj6jfe5Y4dQx6CT8JMEpqJ")
        
        
        //Set up notifications
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        print(launchOptions)
        
        if let options = launchOptions {
            if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
                NSNotificationCenter.defaultCenter().postNotificationName("com.pickup.loadGameFromNotificationWithSegue", object: nil, userInfo: notification.userInfo)
            }
        }
        
        
        //Set up user defaults
        //Intialize first pull of game types. Only pull these once a day
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("gameTypePullTimeStamp") as? NSDate {
            //Pass
        } else {
            let lastPull = NSDate().dateByAddingTimeInterval(-25 * 60 * 60) //Default to a day ago
            NSUserDefaults.standardUserDefaults().setObject(lastPull, forKey: "gameTypePullTimeStamp")
        }
        
        //Initialize settings
        if let settingsFromUserDefaults = NSUserDefaults.standardUserDefaults().objectForKey("settings") as? [String: String] {
            
            let storedSettings = Settings.deserializeSettings(settingsFromUserDefaults)
            Settings.sharedSettings.gameDistance = storedSettings.gameDistance
            Settings.sharedSettings.distanceUnit = storedSettings.distanceUnit
            Settings.sharedSettings.gameReminder = storedSettings.gameReminder
            Settings.sharedSettings.defaultLocation = storedSettings.defaultLocation
            Settings.sharedSettings.showCreatedGames = storedSettings.showCreatedGames
            
        } else {
            let settings = Settings.sharedSettings
            let serializedSettings = Settings.serializeSettings(settings)
            NSUserDefaults.standardUserDefaults().setObject(serializedSettings, forKey: "settings")
        }
        
        //Set up current user
        let currentUser = PFUser.currentUser()
        
        if currentUser == nil {
            PFAnonymousUtils.logInWithBlock {
                (user: PFUser?, error: NSError?) -> Void in
                if error != nil || user == nil {
                    print("Anonymous login failed.")
                } else {
                    user!["deviceType"] = UIDevice.currentDevice().name
                    user?.saveInBackground()
                }
            }
        }
        
        return true
    }
    
//    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
//        
//        "handleLocalNotification"
//        NSNotificationCenter.defaultCenter().postNotificationName("TestingLocalNotifications", object: self)
//        completionHandler()
//    }
    
    func applicationDidBecomeActive(application: UIApplication) {

    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        print("remoteApplicationCalled")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        if (application.applicationState == .Background || application.applicationState == .Inactive) {
            NSNotificationCenter.defaultCenter().postNotificationName("com.pickup.loadGameFromNotificationWithSegue", object: nil, userInfo: notification.userInfo)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("com.pickup.loadGameFromNotificationWithAlert", object: nil, userInfo: notification.userInfo)
        }
        
        
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

