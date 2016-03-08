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
    
    @IBAction func cancelSettings(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func saveSettings(sender: UIBarButtonItem) {
        
        //Save the settings in user defaults
        Settings.sharedSettings.gameDistance = tempSettings.gameDistance
        Settings.sharedSettings.gameReminder = tempSettings.gameReminder
        Settings.sharedSettings.distanceUnit = tempSettings.distanceUnit
        Settings.sharedSettings.defaultLocation = tempSettings.defaultLocation
        Settings.sharedSettings.showCreatedGames = tempSettings.showCreatedGames
        
        let serializedSettings = Settings.serializeSettings(Settings.sharedSettings)
        NSUserDefaults.standardUserDefaults().setObject(serializedSettings, forKey: "settings")
        
        print(NSUserDefaults.standardUserDefaults().objectForKey("settings"))
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func switchShowCreatedGamesChanged(sender: UISwitch) {
        
        if sender.on {
            tempSettings.showCreatedGames = true
        } else {
            tempSettings.showCreatedGames = false
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyles()
        
        tempSettings = Settings.init()
        tempSettings.gameDistance = Settings.sharedSettings.gameDistance
        tempSettings.gameReminder = Settings.sharedSettings.gameReminder
        tempSettings.distanceUnit = Settings.sharedSettings.distanceUnit
        tempSettings.defaultLocation = Settings.sharedSettings.defaultLocation
        tempSettings.showCreatedGames = Settings.sharedSettings.showCreatedGames
        
        self.lblGameDistanceSubtext.text = "Show games within \(tempSettings.gameDistance) \(tempSettings.distanceUnit)"
        
        if tempSettings.showCreatedGames == true {
            self.switchShowCreatedGames.on = true
        } else {
            self.switchShowCreatedGames.on = false
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.lblGameDistanceSubtext.text = "Show games within \(tempSettings.gameDistance) \(tempSettings.distanceUnit)"
        
        //Set game reminder
        checkGameReminderCell()
    }
    
    private func checkGameReminderCell() {
        switch(tempSettings.gameReminder) {
        case 0:
            let indexPath = NSIndexPath(forRow: 0, inSection: 1)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
            break
        case 30:
            let indexPath = NSIndexPath(forRow: 1, inSection: 1)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
            break
        case 60:
            let indexPath = NSIndexPath(forRow: 2, inSection: 1)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
        case 2 * 60:
            let indexPath = NSIndexPath(forRow: 3, inSection: 1)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
        case 24 * 60:
            let indexPath = NSIndexPath(forRow: 4, inSection: 1)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
        default:
            break
        }
    }

    //MARK: - Table View Controller
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch(indexPath.section) {
        case 0:
            if indexPath.row == 0 {
                performSegueWithIdentifier(SEGUE_DISTANCE_SETTINGS, sender: self)
            }
            break
        case 1:
            let uncheckCell = tableView.cellForRowAtIndexPath(getSelectedGameReminderCellIndexPath())
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            
            uncheckCell?.accessoryType = .None
            cell?.accessoryType = .Checkmark
            
            tempSettings.gameReminder = self.selectedCellGameReminder[indexPath.row]
            
            break
        case 2:
            performSegueWithIdentifier(SEGUE_ABOUT, sender: self)
            break
        default:
            break
        }
    }
    
    private func getSelectedGameReminderCellIndexPath() -> NSIndexPath {
        
        var indexPath: NSIndexPath
        
        switch(tempSettings.gameReminder) {
        case 30:
            indexPath = NSIndexPath(forRow: 1, inSection: 1)
            break
        case 60:
            indexPath = NSIndexPath(forRow: 2, inSection: 1)
            break
        case 2 * 60:
            indexPath = NSIndexPath(forRow: 3, inSection: 1)
            break
        case 24 * 60:
            indexPath = NSIndexPath(forRow: 4, inSection: 1)
            break
        default:
            indexPath = NSIndexPath(forRow: 0, inSection: 1)
            break
        }
        
        return indexPath
    }


    //MARK: - Main Settings Delegate
    func updateTempSettings(tempSettings: Settings) {
        self.tempSettings = tempSettings
    }
    
    
    //MARK: - Styles
    func applyStyles() {
        btnSave.tintColor = Theme.ACCENT_COLOR
        btnSave.style = .Done
        switchShowCreatedGames.onTintColor = Theme.ACCENT_COLOR
        btnCancel.tintColor = Theme.PRIMARY_LIGHT_COLOR
    }
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_DISTANCE_SETTINGS {
            let locationSettingsTableViewController = segue.destinationViewController as! LocationSettingsTableViewController
                locationSettingsTableViewController.settingsDelegate = self
                locationSettingsTableViewController.tempSettings = self.tempSettings
        }
    }
    
    
    
    


}
