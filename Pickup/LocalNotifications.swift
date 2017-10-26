//
//  LocalNotifications.swift
//  Pickup
//
//  Created by Nathan Dudley on 4/4/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import UIKit

struct LocalNotifications {
    
    //MARK: - Notifications
    //https://www.hackingwithswift.com/example-code/system/how-to-set-local-alerts-using-uilocalnotification
    static func scheduleGameNotification(_ game: Game) {
        
        let settings = UIApplication.shared.currentUserNotificationSettings
        
        if settings!.types != UIUserNotificationType() && Settings.shared.gameReminder != 0 {
            let notification = UILocalNotification()
            
            
            let timeUntilGame = (Calendar.current as NSCalendar).components(.minute, from: Date(), to: game.eventDate as Date, options: []).minute
            let timeUntilGameString = getTimeUntilGameFromSettings(timeUntilGame!, gameReminder: Settings.shared.gameReminder)
            
            notification.fireDate = game.eventDate.addingTimeInterval(-1 * Double(Settings.shared.gameReminder) * 60) as Date
            
            var showAlert = "true"
            
            if timeUntilGame! < Settings.shared.gameReminder {
                showAlert = "false"
            }
            
            let alertBody = "Your \(game.gameType.name) game at \(game.locationName) starts \(timeUntilGameString)."
            notification.alertBody = alertBody
            
            notification.soundName = UILocalNotificationDefaultSoundName
            
            notification.userInfo = ["selectedGameId": game.id,
                                     "locationName": game.locationName,
                                     "gameType": game.gameType.name,
                                     "alertBody": alertBody,
                                     "showAlert": showAlert]
            
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    static func getTimeUntilGameFromSettings(_ timeUntilGame: Int, gameReminder: Int) -> String {
        
        var gameNotification: String
        print("TimeUntilGame: \(timeUntilGame)")
        
        
        switch (gameReminder) {
        case 30:
            if timeUntilGame < 30 {
                gameNotification = "in \(timeUntilGame) minutes"
            } else {
                gameNotification = "in 30 minutes"
            }
            break
        case 60:
            if timeUntilGame < 60 {
                gameNotification = "in \(timeUntilGame) minutes"
            } else {
                gameNotification = "in 1 hour"
            }
            break
        case 60 * 2:
            if timeUntilGame < 60 * 2 {
                gameNotification = "in 1 hour and \(timeUntilGame % 60) minutes"
            } else {
                gameNotification = "in 2 hours"
            }
            break
        case 60 * 24:
            if timeUntilGame < 60 * 24 {
                gameNotification = "within 24 hours"
            } else {
                gameNotification = "in 24 hours"
            }
            break
        default:
            gameNotification = "soon"
            break
        }
        
        return gameNotification
    }
    
    static func cancelGameNotification(_ game: Game) {
        for notification in UIApplication.shared.scheduledLocalNotifications! {// as! [UILocalNotification] {
            if notification.userInfo!["selectedGameId"] as! String == game.id {
                UIApplication.shared.cancelLocalNotification(notification)
            }
        }
    }
    
    
}
