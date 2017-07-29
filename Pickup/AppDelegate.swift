//
//  AppDelegate.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/18/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        Theme.applyTheme()
        
        OverallLocation.manager.requestWhenInUseAuthorization()
        
        GameController.shared.loadGames { (Games) in
            DispatchQueue.main.async {
                loadedGames = Games
            }
        }
        
        //Set up current user
        
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
        if let settingsFromUserDefaults = UserDefaults.standard.object(forKey: "Settings") as? [String: String] {
            
            let storedSettings = Settings.deserializeSettings(settingsFromUserDefaults)
            Settings.shared.gameDistance = storedSettings.gameDistance
            Settings.shared.distanceUnit = storedSettings.distanceUnit
            Settings.shared.gameReminder = storedSettings.gameReminder
            Settings.shared.defaultLocation = storedSettings.defaultLocation
            Settings.shared.defaultLatitude = storedSettings.defaultLatitude
            Settings.shared.defaultLongitude = storedSettings.defaultLongitude
            Settings.shared.showCreatedGames = storedSettings.showCreatedGames
            
        } else {
            let serializedSettings = Settings.serializeSettings(Settings.shared)
            Settings.saveSettings(serializedSettings)
        }
        return true
    }
    
    
    //MARK: - Remote notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Setup User
        
        //        let installation = PFInstallation.current()
        //        installation?["user"] = PFUser.current()
        //        installation?.setDeviceTokenFrom(deviceToken)
        //        installation?.saveInBackground()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
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
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        // TODO - Fix settings so they will save properly
        
        let serializedSettings = Settings.serializeSettings(Settings.shared)
        Settings.saveSettings(serializedSettings)
    }
}

