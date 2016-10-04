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
        UserDefaults.standard.set(true, forKey: "notificationsRegistered")
    }
    
    static func notificationsInitiated() -> Bool {
        if let notifactionsRegistered: Bool? = UserDefaults.standard.bool(forKey: "notifactionsRegistered") {
            return notifactionsRegistered!
        }
    }
    
    static func registerNotifications() {
        
        if let notifactionsRegistered: Bool? = UserDefaults.standard.bool(forKey: "notifactionsRegistered") {
            if notifactionsRegistered! == false {
                let application: UIApplication = UIApplication.shared
                
                let userNotificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
                let settings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            }
        }
    }
}
