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

class GameListViewController: UIViewController, UITableViewDelegate, CLLocationManagerDelegate {

    let SEGUE_SHOW_GAME_DETAILS = "showGameDetailsViewController"
    let SEGUE_SHOW_GAMES_MAP = "showGamesMapView"
    
    var sectionTitles:[String] = []
    
    let METERS_IN_MILE = 1609.34
    var selectedGameType:GameType!
    var games:[Game] = [] //TODO: Perhaps add a getset to sort when Parse returns games
    var sortedGames:[[Game]] = [[]]
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    
    @IBOutlet weak var tableGameList: UITableView!
    @IBOutlet weak var btnViewMap: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableGameList.tableFooterView = UIView(frame: CGRect.zero)
        loadGamesFromParse()
        
        self.title = selectedGameType.displayName
        btnViewMap.tintColor = Theme.PRIMARY_DARK_COLOR

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        setUsersCurrentLocation()
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sortedGames.count
    }
    
    
    func tableView(tableView : UITableView,  titleForHeaderInSection section: Int)->String {
        var sectionTitle = ""
        
        if !sectionTitles.isEmpty {
            sectionTitle = sectionTitles[section]
        }
        
        return sectionTitle
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedGames[section].count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> GameTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? GameTableViewCell
        
        if !sortedGames.isEmpty {

            let game = sortedGames[indexPath.section][indexPath.row]
            
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
            
        
        }
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
                    let game = GameConverter.convertParseObject(gameObject, selectedGameType: self.selectedGameType)
                    self.games.append(game)
                }
            }
            
            self.sortedGames = self.sortGamesByDate(self.games)
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
        } else if segue.identifier == SEGUE_SHOW_GAMES_MAP {
            let gameMapViewController = segue.destinationViewController as! GameMapViewController
            gameMapViewController.games = self.games
            gameMapViewController.selectedGameType = self.selectedGameType
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
    
    //MARK: - Sort Dates
    //TODO: Abstract date functions into separate class
    func sortGamesByDate(games: [Game]) -> [[Game]] {

        var todayGames:[Game] = []
        var tomorrowGames:[Game] = []
        var thisWeekGames:[Game] = []
        var nextWeekGames:[Game] = []
        var combinedGamesArray:[[Game]] = [[]]
        
        for game in games {
            
            switch(dateCompare(game.eventDate)) {
                case "TODAY":
                    todayGames.append(game)
                    break
                case "TOMORROW":
                    tomorrowGames.append(game)
                    break
                case "THIS WEEK":
                    thisWeekGames.append(game)
                    break
                case "NEXT WEEK":
                    nextWeekGames.append(game)
                    break
                default:
                    break
            }
        }
        
        combinedGamesArray.removeAll()
        sectionTitles.removeAll()
        
        if !todayGames.isEmpty {
            combinedGamesArray.append(todayGames)
            self.sectionTitles.append("Today")
        }
        
        if !tomorrowGames.isEmpty {
            combinedGamesArray.append(tomorrowGames)
            self.sectionTitles.append("Tomorrow")
        }
        
        if !thisWeekGames.isEmpty {
            combinedGamesArray.append(thisWeekGames)
            self.sectionTitles.append("Later this week")
        }
        
        if !nextWeekGames.isEmpty {
            combinedGamesArray.append(nextWeekGames)
            self.sectionTitles.append("Next week")
        }
        
        return combinedGamesArray
        
    }
    
    //TODO: Make the returned result an enum
    func dateCompare(eventDate: NSDate) -> String {
        
        let dateComparisonResult:NSComparisonResult = NSDate().compare(eventDate)
        var resultString:String = ""
        
        if dateComparisonResult == NSComparisonResult.OrderedAscending || dateComparisonResult == NSComparisonResult.OrderedSame
        {
            let todayWeekday = NSCalendar.currentCalendar().components([.Weekday], fromDate: NSDate()).weekday
            let eventWeekday = NSCalendar.currentCalendar().components([.Weekday], fromDate: eventDate).weekday
            
            if todayWeekday == eventWeekday {
                resultString = "TODAY"
            } else if todayWeekday + 1 == eventWeekday {
                resultString = "TOMORROW"
            } else if eventWeekday > todayWeekday {
                resultString = "THIS WEEK"
            } else {
                resultString = "NEXT WEEK"
            }
        }
        
        return resultString
    }
    

}
