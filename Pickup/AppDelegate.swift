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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Theme.applyTheme()
        
        // Initialize Parse.
        // Parse Licensing Agreement
        // https://parse.com/policies
        
        Parse.setApplicationId("vXTZeIEcllE2fqSPJab5OdZkCbB9TmfW9DIutXJn",
            clientKey: "xUjfmNs7umcLNLUdINYj6jfe5Y4dQx6CT8JMEpqJ")
        
        //Set up current user
        let currentUser = PFUser.current()
        
        if currentUser == nil {
            PFAnonymousUtils.logIn {
                (user: PFUser?, error: Error?) -> Void in
                if error != nil || user == nil {
                    print("Anonymous login failed.")
                } else {
                    user!["deviceType"] = UIDevice.current.name
                    user?.saveInBackground()
                }
            }
        }
        
        if NotificationsManager.notificationsInitiated() {
            NotificationsManager.registerNotifications()
        }
        
        if let options = launchOptions {
            if let notification = options[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "com.pickup.loadGameFromNotificationWithSegue"), object: nil, userInfo: notification.userInfo)
            }
        }
        
        
        //Set up user defaults
        //Intialize first pull of game types. Only pull these once a day
        if let _ = UserDefaults.standard.object(forKey: "gameTypePullTimeStamp") as? Date {
            //Pass
        } else {
            let lastPull = Date().addingTimeInterval(-25 * 60 * 60) //Default to a day ago
            UserDefaults.standard.set(lastPull, forKey: "gameTypePullTimeStamp")
        }
        
        //Initialize settings
        if let settingsFromUserDefaults = UserDefaults.standard.object(forKey: "settings") as? [String: String] {
            
            let storedSettings = Settings.deserializeSettings(settingsFromUserDefaults)
            Settings.sharedSettings.gameDistance = storedSettings.gameDistance
            Settings.sharedSettings.distanceUnit = storedSettings.distanceUnit
            Settings.sharedSettings.gameReminder = storedSettings.gameReminder
            Settings.sharedSettings.defaultLocation = storedSettings.defaultLocation
            Settings.sharedSettings.defaultLatitude = storedSettings.defaultLatitude
            Settings.sharedSettings.defaultLongitude = storedSettings.defaultLongitude
            Settings.sharedSettings.showCreatedGames = storedSettings.showCreatedGames
            
        } else {
            let settings = Settings.sharedSettings
            let serializedSettings = Settings.serializeSettings(settings)
            UserDefaults.standard.set(serializedSettings, forKey: "settings")
        }
        
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {

    }
    

    //MARK: - Remote notifications

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?["user"] = PFUser.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground()
        
//        PFPush.subscribeToChannelInBackgr ound("") { (succeeded: Bool, error: NSError?) in
//            if succeeded {
//                print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
//            } else {
//                print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
//            }
//        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        PFPush.handle(userInfo)
    }
    
    
    //MARK: - Local notifications
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        if (application.applicationState == .background || application.applicationState == .inactive) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "com.pickup.loadGameFromNotificationWithSegue"), object: nil, userInfo: notification.userInfo)
        } else {
            if notification.userInfo!["showAlert"] as? String == "true" {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "com.pickup.loadGameFromNotificationWithAlert"), object: nil, userInfo: notification.userInfo)
            }
        }
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

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

