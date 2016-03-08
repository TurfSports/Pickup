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
    var tempSettings: Settings!
    
    @IBAction func distanceUnitsChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == MILES {
            self.tempSettings.distanceUnit = "miles"
        } else {
            self.tempSettings.distanceUnit = "kilometers"
        }
    }
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.tintColor = Theme.PRIMARY_LIGHT_COLOR
        setGestureRecognizer()
        addTextFieldTargets()
        
        txtGameDistance.text = "\(tempSettings.gameDistance)"
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
        if txtGameDistance.text?.characters.count > 0 {
            var gameDistance = Int(txtGameDistance.text!)!
            if gameDistance > 60 {
                gameDistance = 60
            } else if gameDistance < 1 {
                gameDistance = 1
            }
            
            tempSettings.gameDistance = gameDistance
        }
        
        settingsDelegate.updateTempSettings(self.tempSettings)
    }
    
    func setGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "resignKeyboard")
        self.tableView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func resignKeyboard() {
        txtDefaultLocation.resignFirstResponder()
        txtGameDistance.resignFirstResponder()
    }
    
    
    private func addTextFieldTargets() {
//        txtGameDistance.addTarget(self, action: "textFieldGameDistanceDidChange:", forControlEvents: UIControlEvents.EditingChanged)
//        txtDefaultLocation.addTarget(self, action: "textFieldDefaultLocationDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }

    //MARK: - Text Field Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    //http://stackoverflow.com/a/1773257/3866299
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 2
        

        
    }
    
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
            
            self.tempSettings.gameDistance = distance
        }
    }
    
    func textFieldDefaultLocationDidChange(textField: UITextField) {
 
        
    }
    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        guard let text = textField.text else { return true }
//        let newLength = text.characters.count + string.characters.count - range.length
//        return newLength <= limitLength
//    }


}
