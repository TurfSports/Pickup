//
//  LocationSettingsTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/5/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import MapKit

class LocationSettingsTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate {

    @IBOutlet weak var segCtrlDistanceUnits: UISegmentedControl!
    @IBOutlet weak var txtDefaultLocation: UITextField!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var pickerViewDistance: UIPickerView!
    @IBOutlet weak var switchLocation: UISwitch!
    @IBOutlet weak var zipLabel: UILabel!
    
    private var foregroundNotification: NSObjectProtocol!
    
    let MILES = 0
    
    var settingsDelegate: MainSettingsDelegate!
    var tempSettings: Settings!
    var distanceRowSelected: Bool = false
    var invalidZipCode: Bool = false

    
    @IBAction func distanceUnitsChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == MILES {
            self.tempSettings.distanceUnit = "miles"
        } else {
            self.tempSettings.distanceUnit = "kilometers"
        }
        
        lblDistance.text = "\(tempSettings.gameDistance) \(tempSettings.distanceUnit)"
    }
    
    @IBAction func showDefaultLocation(sender: UISwitch) {
        
        tempSettings.defaultLocation = sender.on ? "84606" : "none"
        animateReloadTableView()
        
        if sender.on {
            txtDefaultLocation.becomeFirstResponder()
            if txtDefaultLocation.text != "" {
                tempSettings.defaultLocation = txtDefaultLocation.text!
            }
        } else {
            tempSettings.defaultLocation = "none"
        }
    }
    

    @IBAction func textFieldEditingChanged(sender: AnyObject) {
        zipLabel.hidden = true
        if txtDefaultLocation.text!.characters.count == 5 {
            validateZipCode(txtDefaultLocation.text!)
            txtDefaultLocation.resignFirstResponder()
        }
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = Theme.PRIMARY_LIGHT_COLOR
        switchLocation.onTintColor = Theme.ACCENT_COLOR
        
        lblDistance.text = "\(tempSettings.gameDistance) \(tempSettings.distanceUnit)"
        
        if tempSettings.defaultLocation == "none" {
            zipLabel.hidden = true
        } else {
            txtDefaultLocation.text = tempSettings.defaultLocation
            validateZipCode(tempSettings.defaultLocation)
            zipLabel.hidden = false
        }
        
        pickerViewDistance.selectRow(tempSettings.gameDistance - 1, inComponent: 0, animated: false)
        
        if tempSettings.defaultLocation != "none" {
            txtDefaultLocation.text = tempSettings.defaultLocation
        }
        
        handleSwitch()
        
        segCtrlDistanceUnits.selectedSegmentIndex = tempSettings.distanceUnit == "miles" ? 0 : 1
        
        switchLocation.on = tempSettings.defaultLocation != "none" ? true : false
        
        foregroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            [unowned self] notification in
            self.handleSwitch()
        }

    }
    
    override func viewWillDisappear(animated: Bool) {
        settingsDelegate.updateTempSettings(self.tempSettings)
    }
    
    func handleSwitch() {
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            self.switchLocation.enabled = false
        } else {
            self.switchLocation.enabled = true
        }
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
        } else if indexPath.section == 1 && indexPath.row == 0 {
            if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
                showLocationAlert()
            }
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
        
        if indexPath.section == 1 && indexPath.row == 1 {
            if tempSettings.defaultLocation == "none" {
                rowHeight = 0.0
            }
        }
        
        return rowHeight
    }
    
    //MARK: - Text Field Delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        print("textFieldDidBeginEditing")
        textField.selectAll(self)
    }
    
    
    //MARK: - Animation
    
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
    
    //MARK: - GeoCode
    
    func validateZipCode(zipcode: String) {

        let geocoder = CLGeocoder()
        self.zipLabel.hidden = false

        geocoder.geocodeAddressString(zipcode, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
                self.zipLabel.text = "Invalid Zip"
            } else if let placemark = placemarks?.first {
                
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                if let city = placemark.addressDictionary!["City"] as? NSString {
                    if let country = placemark.addressDictionary!["Country"] as? NSString {
                        if country == "United States" || country == "Canada" {
                            if let state = placemark.addressDictionary!["State"] as? NSString {
                                self.zipLabel.text = "\(city), \(state)"
                            }
                        } else {
                            self.zipLabel.text = "\(city), \(country)"
                        }
                        
                    }
                }
                
                self.tempSettings.defaultLocation = self.txtDefaultLocation.text!
                self.tempSettings.defaultLatitude = coordinates.latitude
                self.tempSettings.defaultLongitude = coordinates.longitude
            }
        })
    }
    
    //MARK: - Location Alert
    func showLocationAlert() {
        
        let alert = UIAlertController(title: "Static Location", message: "To use your current location instead of a default zipcode, you must enable location services for this app.", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in

        }))
        
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(foregroundNotification)
    }

}
