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
    
    fileprivate var foregroundNotification: NSObjectProtocol!
    
    let MILES = 0
    
    var settingsDelegate: MainSettingsDelegate!
    var tempSettings: Settings!
    var distanceRowSelected: Bool = false
    var invalidZipCode: Bool = false

    
    @IBAction func distanceUnitsChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == MILES {
            self.tempSettings.distanceUnit = "miles"
        } else {
            self.tempSettings.distanceUnit = "kilometers"
        }
        
        lblDistance.text = "\(tempSettings.gameDistance) \(tempSettings.distanceUnit)"
    }
    
    @IBAction func showDefaultLocation(_ sender: UISwitch) {
        
        tempSettings.defaultLocation = sender.isOn ? "84606" : "none"
        animateReloadTableView()
        
        if sender.isOn {
            txtDefaultLocation.becomeFirstResponder()
            if txtDefaultLocation.text != "" {
                tempSettings.defaultLocation = txtDefaultLocation.text!
            }
        } else {
            tempSettings.defaultLocation = "none"
        }
    }
    

    @IBAction func textFieldEditingChanged(_ sender: AnyObject) {
        zipLabel.isHidden = true
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
            zipLabel.isHidden = true
        } else {
            txtDefaultLocation.text = tempSettings.defaultLocation
            validateZipCode(tempSettings.defaultLocation)
            zipLabel.isHidden = false
        }
        
        pickerViewDistance.selectRow(tempSettings.gameDistance - 1, inComponent: 0, animated: false)
        
        if tempSettings.defaultLocation != "none" {
            txtDefaultLocation.text = tempSettings.defaultLocation
        }
        
        handleSwitch()
        
        segCtrlDistanceUnits.selectedSegmentIndex = tempSettings.distanceUnit == "miles" ? 0 : 1
        
        switchLocation.isOn = tempSettings.defaultLocation != "none" ? true : false
        
        foregroundNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            [unowned self] notification in
            self.handleSwitch()
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        settingsDelegate.update(settings: self.tempSettings)
    }
    
    func handleSwitch() {
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            self.switchLocation.isEnabled = false
        } else {
            self.switchLocation.isEnabled = true
        }
    }
    
    
    //MARK: - Picker View Delegate
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 50
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tempSettings.gameDistance = row + 1
        lblDistance.text = "\(tempSettings.gameDistance) \(tempSettings.distanceUnit)"
    }
    
    
    //MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 1 {
            distanceRowSelected = !distanceRowSelected
            animateReloadTableView()
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
                showLocationAlert()
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 44.0
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 2 {
            if distanceRowSelected == false {
                rowHeight = 0.0
            } else {
                rowHeight = 130.0
            }
        }
        
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 {
            if tempSettings.defaultLocation == "none" {
                rowHeight = 0.0
            }
        }
        
        return rowHeight
    }
    
    //MARK: - Text Field Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        textField.selectAll(self)
    }
    
    
    //MARK: - Animation
    
    fileprivate func animateReloadTableView() -> Void {
        UIView.transition(with: tableView,
            duration:0.35,
            options: [.allowAnimatedContent, .transitionCrossDissolve],
            animations:
            { () -> Void in
                self.tableView.reloadData()
            },
            completion: nil);
    }
    
    //MARK: - GeoCode
    
    func validateZipCode(_ zipcode: String) {

        let geocoder = CLGeocoder()
        self.zipLabel.isHidden = false

        geocoder.geocodeAddressString(zipcode, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error ?? "Error in geocoder")
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
        
        let alert = UIAlertController(title: "Static Location", message: "To use your current location instead of a default zipcode, you must enable location services for this app.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in

        }))
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(foregroundNotification)
    }

}
