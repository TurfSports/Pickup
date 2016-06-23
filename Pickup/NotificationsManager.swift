//
//  NotificationsManager.swift
//  Pickup
//
//  Created by Nathan Dudley on 6/22/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import UIKit

class NotificationsManager {
    
    static func setNotificationsAsInitiated() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "notificationsRegistered")
    }
    
    static func notificationsInitiated() -> Bool {
        if let notifactionsRegistered: Bool? = NSUserDefaults.standardUserDefaults().boolForKey("notifactionsRegistered") {
            return notifactionsRegistered!
        }
    }
    
    static func registerNotifications() {
        
        if let notifactionsRegistered: Bool? = NSUserDefaults.standardUserDefaults().boolForKey("notifactionsRegistered") {
            if notifactionsRegistered! == false {
                let application: UIApplication = UIApplication.sharedApplication()
                
                let userNotificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
                let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            }
        }
    }
}
