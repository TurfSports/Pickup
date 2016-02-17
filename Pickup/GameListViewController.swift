//
//  GameListViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/16/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class GameListViewController: UIViewController, UITableViewDelegate, CLLocationManagerDelegate, UITabBarControllerDelegate {

    let SEGUE_SHOW_GAME_DETAILS = "showGameDetailsViewController"
    let METERS_IN_MILE = 1609.34
    var selectedGameType:GameType!
    var games:[Game] = []
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableGameList: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGamesFromParse()
        tabBar.selectedItem = tabBar.items![0] as UITabBarItem
        tabBar.items![0].tag = 0
        tabBar.items![1].tag = 1

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        setUsersCurrentLocation()
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> GameTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? GameTableViewCell
        
        let game = games[indexPath.row]
        
        cell?.lblLocationName.text = game.locationName
        cell?.lblDistance.text = ""
        
        let latitude:CLLocationDegrees = game.latitude
        let longitude:CLLocationDegrees = game.longitude
        let gameLocation:CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        if self.currentLocation != nil {
            if let distance:Double = getDistanceBetweenLocations(gameLocation, location2: self.currentLocation!) {
                cell?.lblDistance.text = "\(distance) mi"
            }
        }
        
        
        return cell!
    }
    
    //MARK: - Tab Bar Delegate
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        print(item.tag)
        if item.tag == 1 {
            print("Here I need to segue")
        }
    }
    
    //MARK: - Parse
    private func loadGamesFromParse() {
        let gameQuery = PFQuery(className: "Game")
        gameQuery.whereKey("gameType", equalTo: PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id))
        gameQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let gameObjects = objects {
                
                self.games.removeAll(keepCapacity: true)
                
                for gameObject in gameObjects {
                    let game = GameConverter.convertParseObject(gameObject, selectedGameType: self.selectedGameType)
                    self.games.append(game)
                }
            }
            
            self.tableGameList.reloadData()
        }
    }

    
    //MARK: - Navigation
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SEGUE_SHOW_GAME_DETAILS, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SHOW_GAME_DETAILS {
            let gameDetailsViewController = segue.destinationViewController as! GameDetailsViewController
            if let indexPath = tableGameList.indexPathForSelectedRow {
                gameDetailsViewController.game = games[indexPath.row]
            }
            
            gameDetailsViewController.navigationItem.leftItemsSupplementBackButton = true
        }
        
    }
    
    //MARK: - Location Delegate
    //TODO: Abstract location methods into their own class
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        if currentLocation != nil {
            locationManager.stopUpdatingLocation()
        }
        
        tableGameList.reloadData()
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
