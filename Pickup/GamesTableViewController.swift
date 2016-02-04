//
//  GamesTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/1/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import CoreLocation

class GamesTableViewController: PFQueryTableViewController, CLLocationManagerDelegate {

    let SEGUE_SHOW_GAME_DETAILS = "showGameDetailsViewController"
    let METERS_IN_MILE = 1609.34
    var gameType:PFObject!
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    
    // Initialise the PFQueryTable tableview
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.parseClassName = "Game"
        self.textKey = "owner"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        setUsersCurrentLocation()
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        setUsersCurrentLocation()
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Game")
        query.whereKey("gameType", equalTo: gameType)
        query.includeKey("owner")
        return query
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        let cell = PFTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        if let locationName = object?["locationName"] as? String {
            cell.textLabel?.text = locationName
        }
        
        if let owner = object?["owner"]["username"] as? String {
            cell.detailTextLabel?.text = owner
        }
        
        if let latitude:CLLocationDegrees = object?["location"].latitude {
            if let longitude:CLLocationDegrees = object?["location"].longitude {
                let gameLocation:CLLocation = CLLocation(latitude: latitude, longitude: longitude)
                if self.currentLocation != nil {
                    if let distance:Double = getDistanceBetweenLocations(gameLocation, location2: self.currentLocation!) {
                        cell.detailTextLabel?.text = "\(distance) mi"
                    }
                }
            }
        }
        
//        Theme.applyThemeToCell(cell)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SEGUE_SHOW_GAME_DETAILS, sender: self)
    }
    
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SHOW_GAME_DETAILS {
            let gameDetailsViewController = segue.destinationViewController as! GameDetailsViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let row = Int(indexPath.row)
                gameDetailsViewController.game = (objects![row])
            }
            gameDetailsViewController.navigationItem.leftItemsSupplementBackButton = true
        }
        
    }
    
    //MARK: - Location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        if currentLocation != nil {
            locationManager.stopUpdatingLocation()
        }
        
        tableView.reloadData()
    }
    
    func setUsersCurrentLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func getDistanceBetweenLocations(location1: CLLocation, location2: CLLocation) -> Double {
        let distance:Double = roundToDecimalPlaces(location1.distanceFromLocation(location2) / METERS_IN_MILE, places: 1)
        return distance
    }
    
    func roundToDecimalPlaces(number: Double, places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(number * divisor) / divisor
    }
    
}
