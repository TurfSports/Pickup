//
//  LocationSettingsTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/5/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit

class LocationSettingsTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate {

    @IBOutlet weak var segCtrlDistanceUnits: UISegmentedControl!
    @IBOutlet weak var txtDefaultLocation: UITextField!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var pickerViewDistance: UIPickerView!
    
    let MILES = 0
    
    var settingsDelegate: MainSettingsDelegate!
    var tempSettings: Settings!
    var distanceRowSelected: Bool = false
    
    @IBAction func distanceUnitsChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == MILES {
            self.tempSettings.distanceUnit = "miles"
        } else {
            self.tempSettings.distanceUnit = "kilometers"
        }
        
        lblDistance.text = "\(tempSettings.gameDistance) \(tempSettings.distanceUnit)"
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.tintColor = Theme.PRIMARY_LIGHT_COLOR
        
        lblDistance.text = "\(tempSettings.gameDistance) \(tempSettings.distanceUnit)"
        
        pickerViewDistance.selectRow(tempSettings.gameDistance - 1, inComponent: 0, animated: false)
        
        if tempSettings.defaultLocation != "none" {
            txtDefaultLocation.text = tempSettings.defaultLocation
        }
        
        if tempSettings.distanceUnit == "miles" {
            segCtrlDistanceUnits.selectedSegmentIndex = 0
        } else {
            segCtrlDistanceUnits.selectedSegmentIndex = 1
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        settingsDelegate.updateTempSettings(self.tempSettings)
    }
    
    

    //MARK: - Picker View Delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 50
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tempSettings.gameDistance = row + 1
        lblDistance.text = "\(tempSettings.gameDistance) \(tempSettings.distanceUnit)"
    }
    
    
    //MARK: - Table View Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 1 {
            distanceRowSelected = !distanceRowSelected
            animateReloadTableView()

        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 44.0
        
        if indexPath.section == 0 && indexPath.row == 2 {
            if distanceRowSelected == false {
                rowHeight = 0.0
            } else {
                rowHeight = 130.0
            }
        }
        
        return rowHeight
        
    }
    
    private func animateReloadTableView() -> Void {
        UIView.transitionWithView(tableView,
            duration:0.35,
            options: [.AllowAnimatedContent, .TransitionCrossDissolve],
            animations:
            { () -> Void in
                self.tableView.reloadData()
            },
            completion: nil);
    }

}
