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

class MyGamesViewController: UIViewController, UITableViewDelegate, CLLocationManagerDelegate, MyGamesTableViewDelegate, DismissalDelegate {

    let METERS_IN_MILE = 1609.34
    let SEGUE_SHOW_GAME_DETAILS = "showGameDetailsViewController"
    let SEGUE_SHOW_NEW_GAME = "showNewGameTableViewController"
    
    
    var newGame: Game!
    var sectionTitles:[String] = []
    var gameTypes:[GameType] = []
    var games:[Game] = []
    var sortedGames:[[Game]] = [[]]
    
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation? {
        didSet {
//            loadGamesFromParse()
            self.tableGameList.reloadData()
        }
    }
    
    @IBOutlet weak var btnAddGame: UIBarButtonItem!
    @IBOutlet weak var tableGameList: UITableView!
    @IBOutlet weak var blurNoGames: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnAddGame.tintColor = Theme.ACCENT_COLOR
        
        let gameTypePullTimeStamp: NSDate = getLastGameTypePull()
        
        if gameTypePullTimeStamp.compare(NSDate().dateByAddingTimeInterval(-24*60*60)) == NSComparisonResult.OrderedAscending {
            loadGameTypesFromParse()
        } else {
            loadGameTypesFromUserDefaults()
        }
        
        self.setUsersCurrentLocation()
        tableGameList.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidAppear(animated: Bool) {
        loadGamesFromParse()
        
        self.tableGameList.reloadData()
    }
    
    //MARK: - Table View Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedGames[section].count
    }
    
    func tableView(tableView : UITableView,  titleForHeaderInSection section: Int)->String {
        return sectionTitles[section]
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> MyGamesTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? MyGamesTableViewCell
        
        if !sortedGames.isEmpty {
            
            let game = sortedGames[indexPath.section][indexPath.row]
            
            cell?.lblLocationName.text = game.locationName
            cell?.lblGameDate.text = relevantDateInfo(game.eventDate)
            cell?.lblDistance.text = ""
            cell?.imgGameType.image = UIImage(named: game.gameType.imageName)
            
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
    
    //MARK: - My Games Table View Delegate
    
    func removeGame(game: Game) {
        
        for index in 0 ... games.count - 1 {
            if game.id == games[index].id {
                games.removeAtIndex(index)
                break
            }
        }
        
        self.sortedGames = self.sortGamesByOwner(games)
        self.tableGameList.reloadData()
    }
    
    //MARK: - User Defaults
    
    private func getLastGameTypePull() -> NSDate {
        
        var lastPull: NSDate
        
        if let lastGameTypePull = NSUserDefaults.standardUserDefaults().objectForKey("gameTypePullTimeStamp") as? NSDate {
            lastPull = lastGameTypePull
        } else {
            lastPull = NSDate().dateByAddingTimeInterval(-25 * 60 * 60)
            NSUserDefaults.standardUserDefaults().setObject(lastPull, forKey: "gameTypePullTimeStamp")
        }
        
        return lastPull
    }
    
    
    private func loadGameTypesFromUserDefaults() {
        
        var gameTypeArray: NSMutableArray = []
        
        if let gameTypeArrayFromDefaults = NSUserDefaults.standardUserDefaults().objectForKey("gameTypes") as? NSArray {
            gameTypeArray = gameTypeArrayFromDefaults.mutableCopy() as! NSMutableArray
            
            for gameType in gameTypeArray {
                self.gameTypes.append(GameType.deserializeGameType(gameType as! [String : String]))
            }
        }
        
    }
    
    private func saveGameTypesToUserDefaults() {
        
        let gameTypeArray: NSMutableArray = []
        
        for gameType in self.gameTypes {
            let serializedGameType = GameType.serializeGameType(gameType)
            gameTypeArray.addObject(serializedGameType)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(gameTypeArray, forKey: "gameTypes")
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "gameTypePullTimeStamp")
    }
    
    
    //MARK: - Parse
    
    private func loadGamesFromParse() {
        let gameQuery = PFQuery(className: "Game")
        
        gameQuery.whereKey("date", greaterThanOrEqualTo: NSDate().dateByAddingTimeInterval(-1.5 * 60 * 60))
        gameQuery.whereKey("date", lessThanOrEqualTo: NSDate().dateByAddingTimeInterval(2 * 7 * 24 * 60 * 60))
        gameQuery.whereKey("objectId", containedIn: getJoinedGamesFromUserDefaults())
        
        gameQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let gameObjects = objects {
                self.games.removeAll(keepCapacity: true)
                
                var gameObjectCount = 0
                
                for gameObject in gameObjects {
                    
                    let gameId = gameObject["gameType"].objectId as String!

                    let game = GameConverter.convertParseObject(gameObject, selectedGameType: self.getGameTypeById(gameId))
                    
                    if gameObject["owner"].objectId == PFUser.currentUser()?.objectId {
                        game.userIsOwner = true
                    }
                    
                    game.userJoined = true
                    self.games.append(game)
                    gameObjectCount += 1
                }
                
                if gameObjectCount == 0 {
                    self.blurNoGames.hidden = false
                }
                
            } else {
                print(error)
            }
            

            
      
            self.sortedGames = self.sortGamesByOwner(self.games)
            self.tableGameList.reloadData()
        }
    }
    
    private func loadGameTypesFromParse() {
        
        let gameTypeQuery = PFQuery(className: "GameType")
        gameTypeQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let gameTypeObjects = objects {
                
                self.gameTypes.removeAll(keepCapacity: true)
                
                for gameTypeObject in gameTypeObjects {
                    let gameType = GameTypeConverter.convertParseObject(gameTypeObject)
                    self.gameTypes.append(gameType)
                }
            }
            
            self.saveGameTypesToUserDefaults()
        }
    }
    
    //MARK: - Sorting functions
    
    private func getGameTypeById (gameId: String) -> GameType {
        
        var returnedGameType = self.gameTypes[0]
        
        for gameType in self.gameTypes {
            if gameId == gameType.id {
                returnedGameType = gameType
                break
            }
        }
        
        return returnedGameType
    }
    
    private func sortGamesByOwner(games: [Game]) -> [[Game]] {
        
        var createdGames:[Game] = []
        var joinedGames:[Game] = []
        var combinedGamesArray:[[Game]] = [[]]
        
        //TODO: This won't work on a new year
        let sortedGameArray = games.sort { (gameOne, gameTwo) -> Bool in
            let firstElementDay = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Year, forDate: gameOne.eventDate)
            let secondElementDay = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Year, forDate: gameTwo.eventDate)
            
            return firstElementDay < secondElementDay
        }
        
        
        for game in sortedGameArray {
            if game.userIsOwner {
                createdGames.append(game)
            } else {
                joinedGames.append(game)
            }
        }
        
        self.sectionTitles.removeAll()
        combinedGamesArray.removeAll()
        
        if !createdGames.isEmpty {
            combinedGamesArray.append(createdGames)
            self.sectionTitles.append("Created Games")
        }
        
        if !joinedGames.isEmpty {
            combinedGamesArray.append(joinedGames)
            self.sectionTitles.append("Joined Games")
        }
        
        return combinedGamesArray
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
    
    //MARK: - Dismissal Delegate
    func finishedShowing(viewController: UIViewController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier(SEGUE_SHOW_GAME_DETAILS, sender: self)
        
        return
    }
    
    func setNewGame(game: Game) {
        self.newGame = game
    }
    
    
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
    
    
    //MARK: - Date Formatting
    
    func relevantDateInfo(eventDate: NSDate) -> String {
        
        var relevantDateString = ""
        
        switch(dateCompare(eventDate)) {
        case "TODAY":
            relevantDateString = "Today  \(DateUtilities.dateString(eventDate, dateFormatString: DateFormatter.TWELVE_HOUR_TIME.rawValue))"
            break
        case "TOMORROW":
            relevantDateString = "Tomorrow  \(DateUtilities.dateString(eventDate, dateFormatString: DateFormatter.TWELVE_HOUR_TIME.rawValue))"
            break
        case "THIS WEEK":
            relevantDateString = DateUtilities.dateString(eventDate, dateFormatString: "\(DateFormatter.WEEKDAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
            break
        case "NEXT WEEK":
            relevantDateString = DateUtilities.dateString(eventDate, dateFormatString: "\(DateFormatter.WEEKDAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
            break
        default:
            break
        }
        
        return relevantDateString
    }
    
    
    //MARK: - User Defaults
    
    private func getJoinedGamesFromUserDefaults() -> [String] {
        
        var joinedGamesIds: [String] = []
        
        if let joinedGames = NSUserDefaults.standardUserDefaults().objectForKey("userJoinedGamesById") as? NSArray {
            let gameIdArray = joinedGames.mutableCopy()
            joinedGamesIds = gameIdArray as! [String]
            
        } else {
            //TODO: Display that there are no joined games
        }
        
        return joinedGamesIds
        
    }
    

    
     //MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_SHOW_GAME_DETAILS {
            
            let gameDetailsViewController = segue.destinationViewController as! GameDetailsViewController
            var game: Game
            
            if newGame != nil {
                game = self.newGame!
            } else {
                let indexPath = tableGameList.indexPathForSelectedRow
                game = sortedGames[indexPath!.section][indexPath!.row]
            }
            
            gameDetailsViewController.game = game
            gameDetailsViewController.gameTypes = self.gameTypes
            
            if game.userIsOwner == true {
                gameDetailsViewController.userStatus = .USER_OWNED
            } else if game.userJoined == true {
                gameDetailsViewController.userStatus = .USER_JOINED
            } else {
                gameDetailsViewController.userStatus = .USER_NOT_JOINED
            }
            
            gameDetailsViewController.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == SEGUE_SHOW_NEW_GAME {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            let newGameTableViewController = navigationController.viewControllers.first as! NewGameTableViewController
            newGameTableViewController.dismissalDelegate = self
            newGameTableViewController.gameTypes = self.gameTypes
            
        }

    }
    

}
