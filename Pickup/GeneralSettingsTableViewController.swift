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
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var switchShowCreatedGames: UISwitch!
    @IBOutlet weak var lblGameDistanceSubtext: UILabel!
    
    var distance: Int! = 10
    var distanceUnit: DistanceUnit! = .MILES
    
    
    @IBAction func cancelSettings(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func saveSettings(sender: UIBarButtonItem) {
        
        //Save the settings in user defaults
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyStyles()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.lblGameDistanceSubtext.text = "Show games within \(distance) \(distanceUnit.rawValue)"
    }

    //MARK: - Table View Controller
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("section: \(indexPath.section) - row: \(indexPath.row)")
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegueWithIdentifier(SEGUE_DISTANCE_SETTINGS, sender: self)
        }
    }
    
    
    //MARK: - Main Settings Delegate
    func updateDistance(distance: Int) {
        self.distance = distance
    }
    
    func updateDistanceUnit(unitType: DistanceUnit) {
        self.distanceUnit = unitType
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
        }
        
    }
    
    


}
