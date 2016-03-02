//
//  MyGamesViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/2/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class MyGamesViewController: UIViewController, UITableViewDelegate, CLLocationManagerDelegate {

    var gameTypes:[GameType]!
    var games:[Game] = []
    
    let METERS_IN_MILE = 1609.34
    let sectionHeaders:[String] = ["Created Games", "Joined Games"]
    
//    let locationManager = CLLocationManager()
//    var currentLocation:CLLocation? {
//        didSet {
//            loadGamesFromParse()
//        }
//    }
    
    @IBOutlet weak var tableGameList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableGameList.tableFooterView = UIView(frame: CGRect.zero)

        // Do any additional setup after loading the view.
    }

    
    //MARK: - Table View Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return sortedGames[section].count
        return 1
    }
    
    func tableView(tableView : UITableView,  titleForHeaderInSection section: Int)->String {
        return sectionHeaders[section]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Theme.GAME_LIST_ROW_HEIGHT
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = Theme.PRIMARY_DARK_COLOR
        header.textLabel?.textAlignment = .Center
    }
    
    
    //MARK: - Table View Data Source
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> GameTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? GameTableViewCell
        
        
        
        return cell!
        
    }
    
    
    
    //MARK: - Parse
    
//    private func loadGamesFromParse() {
//        let gameQuery = PFQuery(className: "Game")
//        let userGeoPoint = PFGeoPoint(latitude: (self.currentLocation?.coordinate.latitude)!, longitude: self.currentLocation!.coordinate.longitude)
//        
//        gameQuery.whereKey("gameType", equalTo: PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id))
//        gameQuery.whereKey("location", nearGeoPoint:userGeoPoint, withinMiles:15.0)
//        gameQuery.whereKey("date", greaterThanOrEqualTo: NSDate().dateByAddingTimeInterval(-1.5 * 60 * 60))
//        gameQuery.whereKey("date", lessThanOrEqualTo: NSDate().dateByAddingTimeInterval(2 * 7 * 24 * 60 * 60))
//        
//        gameQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
//            if let gameObjects = objects {
//                self.games.removeAll(keepCapacity: true)
//                for gameObject in gameObjects {
//                    let game = GameConverter.convertParseObject(gameObject, selectedGameType: self.selectedGameType)
//                    
//                    if let joinedGames = NSUserDefaults.standardUserDefaults().objectForKey("userJoinedGamesById") as? NSArray {
//                        if joinedGames.containsObject(game.id) {
//                            game.userJoined = true
//                        }
//                    }
//                    
//                    self.games.append(game)
//                }
//            }
//            
//            self.sortedGames = self.sortGamesByDate(self.games)
//            self.tableGameList.reloadData()
//        }
//    }
    
    
    
    //MARK: - Location Manager Delegate
    //TODO: Abstract location methods into their own class
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        
//        let location:CLLocationCoordinate2D = manager.location!.coordinate
//        currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
//        
//        if currentLocation != nil {
//            locationManager.stopUpdatingLocation()
//        }
//        
//        tableGameList.reloadData()
//    }
//    
//    func setUsersCurrentLocation() {
//        self.locationManager.requestWhenInUseAuthorization()
//        
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.startUpdatingLocation()
//        }
//    }
//    
//    func getDistanceBetweenLocations(location1: CLLocation, location2: CLLocation) -> Double {
//        let distance:Double = roundToDecimalPlaces(location1.distanceFromLocation(location2) / METERS_IN_MILE, places: 1)
//        return distance
//    }
//    
//    func roundToDecimalPlaces(number: Double, places: Int) -> Double {
//        let divisor = pow(10.0, Double(places))
//        return round(number * divisor) / divisor
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
