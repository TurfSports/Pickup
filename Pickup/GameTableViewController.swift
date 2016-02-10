//
//  GameTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/8/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class GameTableViewController: UITableViewController, CLLocationManagerDelegate {

    let SEGUE_SHOW_GAME_DETAILS = "showGameDetailsViewController"
    let METERS_IN_MILE = 1609.34
    var selectedGameType:GameType!
    var games:[Game] = []
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGamesFromParse()
    }
    
    override func viewDidAppear(animated: Bool) {
        setUsersCurrentLocation()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return games.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> GameTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? GameTableViewCell
        
        let game = games[indexPath.row]
        
        cell?.lblLocationName.text = game.locationName
//        cell?.lblDistance.text = "\(game.)"
        
        return cell!
    }
    

    //MARK: - Parse
    private func loadGamesFromParse() {
        let gameQuery = PFQuery(className: "Game")
        gameQuery.whereKey("gameType", equalTo: PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id))
        gameQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let gameObjects = objects {
                
                self.games.removeAll(keepCapacity: true)
                
                for gameObject in gameObjects {
                    print(gameObject.objectId)
//                    self.games.append(gameObject)
                    let game = GameConverter.convertParseObject(gameObject, selectedGameType: self.selectedGameType)
                    print(game)
                    self.games.append(game)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    
    
    //MARK: - Navigation
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SEGUE_SHOW_GAME_DETAILS, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SHOW_GAME_DETAILS {
            let gameDetailsViewController = segue.destinationViewController as! GameDetailsViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
//                let row = Int(indexPath.row)
//                gameDetailsViewController.game = (objects![row])
            }
            gameDetailsViewController.navigationItem.leftItemsSupplementBackButton = true
        }
        
    }
    


    
    
    //MARK: - Location
    //TODO: Abstract location methods into their own class
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
