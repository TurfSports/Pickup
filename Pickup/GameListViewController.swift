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
    let SEGUE_SHOW_NEW_GAME = "showNewGameTableViewController"
    
    var sectionTitles:[String] = []
    
    let METERS_IN_MILE = 1609.34
    var selectedGameType:GameType!
    var gameTypes:[GameType]!
    var games:[Game] = []
    var sortedGames:[[Game]] = [[]]
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation? {
        didSet {
            loadGamesFromParse()
        }
    }
    
    @IBOutlet weak var btnAddNewGame: UIBarButtonItem!
    @IBOutlet weak var tableGameList: UITableView!
    @IBOutlet weak var btnViewMap: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var noGamesBlur: UIVisualEffectView!
    
    //MARK: - View Lifecycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        tableGameList.tableFooterView = UIView(frame: CGRect.zero)
        
        if selectedGameType.gameCount == 0 {
            noGamesBlur.hidden = false
        }
    
        setUsersCurrentLocation()
        
        self.title = selectedGameType.displayName
        
        btnViewMap.tintColor = Theme.ACCENT_COLOR
        btnAddNewGame.tintColor = Theme.ACCENT_COLOR
        
    }
    
    override func viewDidAppear(animated: Bool) {
        loadGamesFromParse()
        self.tableGameList.reloadData()
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
        return Theme.GAME_LIST_ROW_HEIGHT
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = Theme.PRIMARY_DARK_COLOR
        header.textLabel?.textAlignment = .Center
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SEGUE_SHOW_GAME_DETAILS, sender: self)
    }
    

    //MARK: - Table View Data Source
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> GameTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? GameTableViewCell
        
        if !sortedGames.isEmpty {

            let game = sortedGames[indexPath.section][indexPath.row]
            
            cell?.lblLocationName.text = game.locationName
            cell?.lblGameDate.text = relevantDateInfo(game.eventDate)
            cell?.lblDistance.text = ""
            
            if game.userJoined == true {
                cell?.lblJoined.hidden = false
                cell?.imgCheckCircle.hidden = false
            } else {
                cell?.lblJoined.hidden = true
                cell?.imgCheckCircle.hidden = true
            }
            
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
        let userGeoPoint = PFGeoPoint(latitude: (self.currentLocation?.coordinate.latitude)!, longitude: self.currentLocation!.coordinate.longitude)
        
        gameQuery.whereKey("gameType", equalTo: PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id))
        gameQuery.whereKey("location", nearGeoPoint:userGeoPoint, withinMiles:15.0)
        gameQuery.whereKey("date", greaterThanOrEqualTo: NSDate().dateByAddingTimeInterval(-1.5 * 60 * 60))
        gameQuery.whereKey("date", lessThanOrEqualTo: NSDate().dateByAddingTimeInterval(2 * 7 * 24 * 60 * 60))
        gameQuery.whereKey("isCancelled", equalTo: false)
        
        gameQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let gameObjects = objects {
                self.games.removeAll(keepCapacity: true)
                for gameObject in gameObjects {
                    let game = GameConverter.convertParseObject(gameObject, selectedGameType: self.selectedGameType)
                    
                    if let joinedGames = NSUserDefaults.standardUserDefaults().objectForKey("userJoinedGamesById") as? NSArray {
                        if joinedGames.containsObject(game.id) {
                            game.userJoined = true
                        }
                    }
                    
                    self.games.append(game)
                }
            }
            
            self.sortedGames = self.sortGamesByDate(self.games)
            self.tableGameList.reloadData()
        }
    }

    
    //MARK: - Location Manager Delegate
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
        
        //Sort the games with earliest game first
        //TODO: This won't work on a new year
        let sortedGameArray = games.sort { (gameOne, gameTwo) -> Bool in
            let firstElementDay = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Year, forDate: gameOne.eventDate)
            let secondElementDay = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Year, forDate: gameTwo.eventDate)
            
            return firstElementDay < secondElementDay
        }
        
        for game in sortedGameArray {
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
    
    //TODO: Make the returned result an enum. Abstract out to Date Utilities
    func dateCompare(eventDate: NSDate) -> String {
        
        let dateToday: NSDate = NSDate().dateByAddingTimeInterval(-1.5 * 60 * 60)
        
        let dateComparisonResult:NSComparisonResult = dateToday.compare(eventDate)
        var resultString:String = ""
        
        if dateComparisonResult == NSComparisonResult.OrderedAscending || dateComparisonResult == NSComparisonResult.OrderedSame
        {
            let todayWeekday = NSCalendar.currentCalendar().components([.Weekday], fromDate: NSDate()).weekday
            let eventWeekday = NSCalendar.currentCalendar().components([.Weekday], fromDate: eventDate).weekday
            
            let today = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Year, forDate: NSDate())
            let eventDay = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Year, forDate: eventDate)
            
            if todayWeekday == eventWeekday && today == eventDay {
                resultString = "TODAY"
            } else if todayWeekday + 1 == eventWeekday && today + 1 == eventDay  {
                resultString = "TOMORROW"
            } else if eventWeekday > todayWeekday && today + 7 >= eventDay {
                resultString = "THIS WEEK"
            } else {
                resultString = "NEXT WEEK"
            }
        }
        
        return resultString
    }
    
    func relevantDateInfo(eventDate: NSDate) -> String {
        
        var relevantDateString = ""
        
        switch(dateCompare(eventDate)) {
            case "TODAY":
                relevantDateString = DateUtilities.dateString(eventDate, dateFormatString: DateFormatter.TWELVE_HOUR_TIME.rawValue)
                break
            case "TOMORROW":
                relevantDateString = DateUtilities.dateString(eventDate, dateFormatString: DateFormatter.TWELVE_HOUR_TIME.rawValue)
                break
            case "THIS WEEK":
                relevantDateString = DateUtilities.dateString(eventDate, dateFormatString: "\(DateFormatter.WEEKDAY.rawValue) \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
                break
            case "NEXT WEEK":
                relevantDateString = DateUtilities.dateString(eventDate, dateFormatString: "\(DateFormatter.WEEKDAY.rawValue) \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
                break
            default:
                break
        }
        
        return relevantDateString
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SHOW_GAME_DETAILS {
            
            let gameDetailsViewController = segue.destinationViewController as! GameDetailsViewController
            if let indexPath = tableGameList.indexPathForSelectedRow {
                let game = sortedGames[indexPath.section][indexPath.row]
                
                gameDetailsViewController.game = game
                gameDetailsViewController.gameTypes = self.gameTypes
                
                if game.userJoined == true {
                    gameDetailsViewController.userStatus = .USER_JOINED
                } else {
                    gameDetailsViewController.userStatus = .USER_NOT_JOINED
                }
            }
            
            gameDetailsViewController.navigationItem.leftItemsSupplementBackButton = true
            
        } else if segue.identifier == SEGUE_SHOW_GAMES_MAP {
            
            let gameMapViewController = segue.destinationViewController as! GameMapViewController
            gameMapViewController.games = self.games
            gameMapViewController.selectedGameType = self.selectedGameType
            
        } else if segue.identifier == SEGUE_SHOW_NEW_GAME {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            let newGameTableViewController = navigationController.viewControllers.first as! NewGameTableViewController
            newGameTableViewController.gameTypes = self.gameTypes
            newGameTableViewController.selectedGameType = self.selectedGameType
        }
        
    }
    

}
