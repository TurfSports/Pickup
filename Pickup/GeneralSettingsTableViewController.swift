//
//  GeneralSettingsTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/5/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit

class GeneralSettingsTableViewController: UITableViewController, MainSettingsDelegate {

    let SEGUE_DISTANCE_SETTINGS = "showDistanceSettings"
    let SEGUE_ABOUT = "showAboutViewController"
    
    let selectedCellGameReminder: [Int] = [0, 30, 60, 2 * 60, 24 * 60]
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var switchShowCreatedGames: UISwitch!
    @IBOutlet weak var lblGameDistanceSubtext: UILabel!
    
    var tempSettings: Settings!
    
    @IBAction func cancelSettings(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func saveSettings(_ sender: UIBarButtonItem) {
        
        //Save the settings in user defaults
        Settings.shared.gameDistance = tempSettings.gameDistance
        Settings.shared.distanceUnit = tempSettings.distanceUnit
        Settings.shared.defaultLocation = tempSettings.defaultLocation
        Settings.shared.defaultLatitude = tempSettings.defaultLatitude
        Settings.shared.defaultLongitude = tempSettings.defaultLongitude
        Settings.shared.showCreatedGames = tempSettings.showCreatedGames
        if Settings.shared.gameReminder != tempSettings.gameReminder {
            updateLocalGameNotifications(tempSettings.gameReminder)
            Settings.shared.gameReminder = tempSettings.gameReminder
        }
        
        let serializedSettings = Settings.serializeSettings(Settings.shared)
        UserDefaults.standard.set(serializedSettings, forKey: "settings")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchShowCreatedGamesChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            tempSettings.showCreatedGames = true
        } else {
            tempSettings.showCreatedGames = false
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyles()
        
        tempSettings = Settings.init()
        tempSettings.gameDistance = Settings.shared.gameDistance
        tempSettings.gameReminder = Settings.shared.gameReminder
        tempSettings.distanceUnit = Settings.shared.distanceUnit
        tempSettings.defaultLocation = Settings.shared.defaultLocation
        tempSettings.defaultLatitude = Settings.shared.defaultLatitude
        tempSettings.defaultLongitude = Settings.shared.defaultLongitude
        tempSettings.showCreatedGames = Settings.shared.showCreatedGames
        
        self.lblGameDistanceSubtext.text = "Show games within \(tempSettings.gameDistance) \(tempSettings.distanceUnit)"
        
        if tempSettings.showCreatedGames == true {
            self.switchShowCreatedGames.isOn = true
        } else {
            self.switchShowCreatedGames.isOn = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.lblGameDistanceSubtext.text = "Show games within \(tempSettings.gameDistance) \(tempSettings.distanceUnit)"
        
        //Set game reminder
        checkGameReminderCell()
    }
    
    fileprivate func checkGameReminderCell() {
        switch(tempSettings.gameReminder) {
        case 1:
            let indexPath = IndexPath(row: 0, section: 1)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            break
        case 30:
            let indexPath = IndexPath(row: 1, section: 1)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            break
        case 60:
            let indexPath = IndexPath(row: 2, section: 1)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
        case 2 * 60:
            let indexPath = IndexPath(row: 3, section: 1)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
        case 24 * 60:
            let indexPath = IndexPath(row: 4, section: 1)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
        default:
            break
        }
    }

    //MARK: - Table View Controller
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch((indexPath as NSIndexPath).section) {
        case 1:
            if (indexPath as NSIndexPath).row == 0 {
                performSegue(withIdentifier: SEGUE_DISTANCE_SETTINGS, sender: self)
            }
            break
        case 2:
            let uncheckCell = tableView.cellForRow(at: getSelectedGameReminderCellIndexPath())
            let cell = tableView.cellForRow(at: indexPath)
            	
            uncheckCell?.accessoryType = .none
            cell?.accessoryType = .checkmark
            
            tempSettings.gameReminder = self.selectedCellGameReminder[(indexPath as NSIndexPath).row]
            
            break
        case 3:
            performSegue(withIdentifier: SEGUE_ABOUT, sender: self)
            break
        default:
            break
        }
    }
    
    fileprivate func getSelectedGameReminderCellIndexPath() -> IndexPath {
        
        var indexPath: IndexPath
        
        switch(tempSettings.gameReminder) {
        case 30:
            indexPath = IndexPath(row: 1, section: 1)
            break
        case 60:
            indexPath = IndexPath(row: 2, section: 1)
            break
        case 2 * 60:
            indexPath = IndexPath(row: 3, section: 1)
            break
        case 24 * 60:
            indexPath = IndexPath(row: 4, section: 1)
            break
        default:
            indexPath = IndexPath(row: 0, section: 1)
            break
        }
        
        return indexPath
    }


    //MARK: - Main Settings Delegate
    func updateTempSettings(_ tempSettings: Settings) {
        self.tempSettings = tempSettings
    }
    
    
    //MARK: - Styles
    func applyStyles() {
        btnSave.tintColor = Theme.ACCENT_COLOR
        btnSave.style = .done
        switchShowCreatedGames.onTintColor = Theme.ACCENT_COLOR
        btnCancel.tintColor = Theme.PRIMARY_LIGHT_COLOR
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SEGUE_DISTANCE_SETTINGS {
            let locationSettingsTableViewController = segue.destination as! LocationSettingsTableViewController
                locationSettingsTableViewController.settingsDelegate = self
                locationSettingsTableViewController.tempSettings = self.tempSettings
        }
    }
    
    //MARK: - Update Local Notifications
    func updateLocalGameNotifications(_ gameReminder: Int) {
        if let joinedGames = UserDefaults.standard.object(forKey: "userJoinedGamesById") as? NSArray {
            for gameId in joinedGames {
                for notification in UIApplication.shared.scheduledLocalNotifications! {// as! [UILocalNotification] {
                    if notification.userInfo!["selectedGameId"] as! String == gameId as! String {
                        
                        
                        let originalFireDate = notification.fireDate
                        let gameDate = originalFireDate?.addingTimeInterval(Double((Settings.shared.gameReminder) * 60))
                        
                        let timeUntilGame = (Calendar.current as NSCalendar).components(.minute, from: Date(), to: gameDate!, options: []).minute
                        
                        let newFireDate = originalFireDate?.addingTimeInterval(Double((tempSettings.gameReminder - Settings.shared.gameReminder) * -60))
                        
                        //Get attributes from user data and then create game in order to schedule local notification
                        let gameId = notification.userInfo!["selectedGameId"] as! String
                        let locationName = notification.userInfo!["locationName"] as! String
                        let gameType = notification.userInfo!["gameType"] as! String
                        
                        let alertBody = "Your \(gameType) game at \(locationName) starts \(LocalNotifications.getTimeUntilGameFromSettings(timeUntilGame!, gameReminder: tempSettings.gameReminder))."
                        
                        let newNotification = UILocalNotification()
                        
                        newNotification.fireDate = newFireDate
                        newNotification.alertBody = alertBody
                        newNotification.soundName = UILocalNotificationDefaultSoundName
                        newNotification.userInfo = ["selectedGameId": gameId,
                                                    "locationName": locationName,
                                                    "gameType": gameType,
                                                    "alertBody": alertBody,
                                                    "showAlert": "true"]
                        
                        UIApplication.shared.cancelLocalNotification(notification)
                        UIApplication.shared.scheduleLocalNotification(newNotification)
                        
//                        print("originalFireDate: \(originalFireDate)")
//                        print("newFireDate: \(newFireDate)")
//                        print("gameDate: \(gameDate)")
//                        print("timeUntilGame: \(timeUntilGame)")
//                        
//                        print("previousAlertBody: \(notification.alertBody)")
//                        print("newAlertBody: \(alertBody)")

                    }
                }
            }
        }
        
    }

}
