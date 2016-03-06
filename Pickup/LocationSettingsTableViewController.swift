//
//  LocationSettingsTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/5/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit

class LocationSettingsTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var segCtrlDistanceUnits: UISegmentedControl!
    @IBOutlet weak var txtGameDistance: UITextField!
    @IBOutlet weak var txtDefaultLocation: UITextField!
    
    let MILES = 0
    
    var settingsDelegate: MainSettingsDelegate!
    var distance: Int!
    var distanceUnit: DistanceUnit!
    
    @IBAction func distanceUnitsChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == MILES {
            self.distanceUnit = .MILES
        } else {
            self.distanceUnit = .KILOMETERS
        }
    }
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = Theme.PRIMARY_LIGHT_COLOR
        addTextFieldTargets()
        
        //This needs to change to get user defaults
        self.distanceUnit = .MILES
        //Set controls to user defaults
        

    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if txtGameDistance.text != "" {
            settingsDelegate.updateDistance(self.distance)
        }
        
        settingsDelegate.updateDistanceUnit(self.distanceUnit)
    }
    
    
    private func addTextFieldTargets() {
        txtGameDistance.addTarget(self, action: "textFieldGameDistanceDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        txtDefaultLocation.addTarget(self, action: "textFieldDefaultLocationDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }

    //MARK: - Text Field Delegate
    func textFieldGameDistanceDidChange(textField: UITextField) {
        
        if let userInputDistance = Int(txtGameDistance.text!) {
            var distance = userInputDistance
            
            if distance > 60 {
                distance = 60
                txtGameDistance.text = "\(distance)"
            } else if distance < 1 {
                distance = 1
                txtGameDistance.text = "\(distance)"
            }
            
            self.distance = distance
        }
        
        
        //Update user settings
    }
    
    func textFieldDefaultLocationDidChange(textField: UITextField) {
 
        
    }
    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        guard let text = textField.text else { return true }
//        let newLength = text.characters.count + string.characters.count - range.length
//        return newLength <= limitLength
//    }


}
