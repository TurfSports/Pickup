//
//  MyGamesViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/2/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

let reloadMyGamesViewNotification: Notification.Name = Notification.Name.init("reloadMyGamesViewNotifcation")

class MyGamesViewController: UIViewController, UITableViewDelegate, CLLocationManagerDelegate, MyGamesTableViewDelegate, DismissalDelegate {

    let METERS_IN_MILE = 1609.34
    let METERS_IN_KILOMETER = 1000.0
    let SEGUE_SHOW_GAME_DETAILS = "showGameDetailsViewController"
    let SEGUE_SHOW_NEW_GAME = "showNewGameTableViewController"
    
    
    var newGame: Game!
    var sectionTitles:[String] = []
    var gameTypes:[GameType] = []
    var games:[Game] = []
    var sortedGames:[Game] = []
    var createdGames:[Game] = []
    var joinedGames:[Game] = []
    
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation? {
        didSet {
            self.tableGameList.reloadData()
        }
    }
    
    @IBOutlet weak var btnSettings: UIBarButtonItem!
    @IBOutlet weak var btnAddGame: UIBarButtonItem!
    @IBOutlet weak var tableGameList: UITableView!
    @IBOutlet weak var blurNoGames: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(gamesWereLoaded), name: gamesLoadedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.manuallyReloadTableView), name: reloadMyGamesViewNotification, object: nil)
        
        OverallLocation.manager.delegate = self
        
        self.btnAddGame.tintColor = Theme.ACCENT_COLOR
        self.btnSettings.tintColor = Theme.PRIMARY_LIGHT_COLOR
        
        let gameTypePullTimeStamp: Date = getLastGameTypePull()
        
        if gameTypePullTimeStamp.compare(Date().addingTimeInterval(-24*60*60)) != ComparisonResult.orderedAscending {
            loadGameTypesFromUserDefaults()
        }
        
        self.setUsersCurrentLocation()
        tableGameList.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        blurNoGames.isHidden = true
        self.tableGameList.reloadData()
        if loadedGames.count > games.count {
            gamesWereLoaded()
        }
    }
    
    @objc func gamesWereLoaded() {
        self.games = loadedGames
        sortedGames = sortGamesByOwner(self.games)
        self.tableGameList.reloadData()
    }
    
    @objc func manuallyReloadTableView() {
        self.sortedGames = self.sortGamesByOwner(loadedGames)
        self.tableGameList.reloadData()
    }
    
    //MARK: - Table View Delegate
    
    @objc func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && sectionTitles[0] == "Created Games" {
            return createdGames.count
        } else if section == 1 || sectionTitles[0] == "Joined Games" {
            return joinedGames.count
        } else {
            return 0
        }
    }
    
    @objc func tableView(_ tableView : UITableView, titleForHeaderInSection section: Int) -> String {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.GAME_LIST_ROW_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = Theme.PRIMARY_DARK_COLOR
        header.textLabel?.textAlignment = .center
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SEGUE_SHOW_GAME_DETAILS, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Table View Data Source
    
    @objc func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> MyGamesTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? MyGamesTableViewCell
        
        var correctSortedGames: [Game] = []
        
        if indexPath.section == 0 && sectionTitles[0] == "Created Games" {
            correctSortedGames = createdGames
        } else if indexPath.section == 1  || sectionTitles [0] == "Joined Games" {
            correctSortedGames = joinedGames
        } else {
            return cell!
        }
        
        guard correctSortedGames.count >= indexPath.row + 1 else { return cell! }
        
        let game = correctSortedGames[indexPath.row]
        
        if !sortedGames.isEmpty {
            
            cell?.lblLocationName.text = game.locationName
            cell?.lblGameDate.text = relevantDateInfo(game.eventDate)
            cell?.lblDistance.text = ""
            cell?.imgGameType.image = UIImage(named: game.gameType.imageName)
            
            let latitude:CLLocationDegrees = game.latitude
            let longitude:CLLocationDegrees = game.longitude
            let gameLocation:CLLocation = CLLocation(latitude: latitude, longitude: longitude)
            if self.currentLocation != nil && Settings.shared.defaultLocation == "none" {
            let distance: Double = getDistanceBetweenLocations(gameLocation, location2: self.currentLocation!)
                    var suffix = "mi"
                if Settings.shared.distanceUnit == "kilometers" {
                    suffix = "km"
                }
                cell?.lblDistance.text = "\(distance) \(suffix)"
            }
        }
    
        return cell!
        
    }
    
    //MARK: - My Games Table View Delegate
    
    func removeGame(_ game: Game) {
        
        for index in 0 ... games.count - 1 {
            if game.id == games[index].id {
                games.remove(at: index)
                break
            }
        }
        
        self.sortedGames = self.sortGamesByOwner(games)
        self.tableGameList.reloadData()
    }
    
    //MARK: - User Defaults
    
    fileprivate func getLastGameTypePull() -> Date {
        
        var lastPull: Date
        
        if let lastGameTypePull = UserDefaults.standard.object(forKey: "gameTypePullTimeStamp") as? Date {
            lastPull = lastGameTypePull
        } else {
            lastPull = Date().addingTimeInterval(-25 * 60 * 60)
            UserDefaults.standard.set(lastPull, forKey: "gameTypePullTimeStamp")
        }
        
        return lastPull
    }
    
    
    fileprivate func loadGameTypesFromUserDefaults() {
        
        var gameTypeArray: NSMutableArray = []
        
        if let gameTypeArrayFromDefaults = UserDefaults.standard.object(forKey: "gameTypes") as? NSArray {
            gameTypeArray = gameTypeArrayFromDefaults.mutableCopy() as! NSMutableArray
            
            for gameType in gameTypeArray {
                guard let castedGameType = GameType(dictionary: gameType as! [String: Any]) else { continue }
                self.gameTypes.append(castedGameType)
            }
        }
        
    }
    
    fileprivate func saveGameTypesToUserDefaults() {
        
        var gameTypeArray: [GameType] = []
        
        for gameType in self.gameTypes {
            gameTypeArray.append(gameType)
        }
        
        UserDefaults.standard.set(gameTypeArray, forKey: "gameTypes")
        UserDefaults.standard.set(Date(), forKey: "gameTypePullTimeStamp")
    }
    
    
    //MARK: - Sorting functions
    
    fileprivate func getGameTypeById (_ gameId: String) -> GameType {
        
        var returnedGameType = self.gameTypes[0]
        
        for gameType in self.gameTypes {
            if gameId == gameType.name {
                returnedGameType = gameType
                break
            }
        }
        
        return returnedGameType
    }
    
    fileprivate func sortGamesByOwner(_ games: [Game]) -> [Game] {
        
        var createdGames:[Game] = []
        var joinedGames:[Game] = []
        var combinedGamesArray:[Game] = []
        
        //TODO: This won't work on a new year
        let sortedGameArray = games.sorted { (gameOne, gameTwo) -> Bool in
            let firstElementDay = (Calendar.current as NSCalendar).ordinality(of: .day, in: .year, for: gameOne.eventDate)
            let secondElementDay = (Calendar.current as NSCalendar).ordinality(of: .day, in: .year, for: gameTwo.eventDate)
            
            return firstElementDay < secondElementDay
        }
        
        
        for game in sortedGameArray {
            if game.userIsOwner {
                createdGames.append(game)
            } else {
                if game.userIDs.contains(currentPlayer.id) {
                    joinedGames.append(game)
                }
            }
        }
        
        self.sectionTitles.removeAll()
        combinedGamesArray.removeAll()
        
        if !createdGames.isEmpty {
            self.createdGames = createdGames
            for game in createdGames {
                combinedGamesArray.append(game)
            }
            self.sectionTitles.append("Created Games")

        }
        
        if !joinedGames.isEmpty {
            self.joinedGames = joinedGames
            for game in joinedGames {
                combinedGamesArray.append(game)
            }
            self.sectionTitles.append("Joined Games")
        }
        
        return combinedGamesArray
    }
    
    
    
    //MARK: - Location Manager Delegate
    //TODO: Abstract location methods into their own class
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = manager.location else { manager.stopUpdatingLocation(); return }
        let locationCordinate: CLLocationCoordinate2D = location.coordinate
        
        manager.stopUpdatingLocation()
        guard currentLocation != nil else { currentLocation = location; self.tableGameList.reloadData();return }
        if getDistanceBetweenLocations(location, location2: currentLocation!) >= CLLocationDistance.init(500) {
            currentLocation = CLLocation(latitude: locationCordinate.latitude, longitude: locationCordinate.longitude)
            tableGameList.reloadData()
        }
    }
    
    func setUsersCurrentLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func getDistanceBetweenLocations(_ location1: CLLocation, location2: CLLocation) -> Double {
        
        var distanceUnitMeasurement: Double
        
        if Settings.shared.distanceUnit == "miles" {
            distanceUnitMeasurement = METERS_IN_MILE
        } else {
            distanceUnitMeasurement = METERS_IN_KILOMETER
        }
        
        let distance:Double = roundToDecimalPlaces(location1.distance(from: location2) / distanceUnitMeasurement, places: 1)
        return distance
    }
    
    func roundToDecimalPlaces(_ number: Double, places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(number * divisor) / divisor
    }
    
    //MARK: - Dismissal Delegate
    func finishedShowing(_ viewController: UIViewController) {
        
        self.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: SEGUE_SHOW_GAME_DETAILS, sender: self)
        
        return
    }
    
    func setNewGame(_ game: Game) {
        self.newGame = game
    }
    
    
    func dateCompare(_ eventDate: Date) -> String {
        
        let dateToday: Date = Date().addingTimeInterval(-1.5 * 60 * 60)
        
        let dateComparisonResult:ComparisonResult = dateToday.compare(eventDate)
        var resultString:String = ""
        
        if dateComparisonResult == ComparisonResult.orderedAscending || dateComparisonResult == ComparisonResult.orderedSame
        {
            let todayWeekday = (Calendar.current as NSCalendar).components([.weekday], from: Date()).weekday
            let eventWeekday = (Calendar.current as NSCalendar).components([.weekday], from: eventDate).weekday
            
            let today = (Calendar.current as NSCalendar).ordinality(of: .day, in: .year, for: Date())
            let eventDay = (Calendar.current as NSCalendar).ordinality(of: .day, in: .year, for: eventDate)
            
            if todayWeekday == eventWeekday && today == eventDay {
                resultString = "TODAY"
            } else if todayWeekday! + 1 == eventWeekday! && today + 1 == eventDay  {
                resultString = "TOMORROW"
            } else if eventWeekday! > todayWeekday! && today + 7 >= eventDay {
                resultString = "THIS WEEK"
            } else {
                resultString = "NEXT WEEK"
            }
        }
        
        return resultString
    }
    
    
    //MARK: - Date Formatting
    
    func relevantDateInfo(_ eventDate: Date) -> String {
        
        var relevantDateString = ""
        
        switch(dateCompare(eventDate)) {
        case "TODAY":
            relevantDateString = "Today  \(DateUtilities.dateString(eventDate, dateFormat: DateFormatter.TWELVE_HOUR_TIME.rawValue))"
            break
        case "TOMORROW":
            relevantDateString = "Tomorrow  \(DateUtilities.dateString(eventDate, dateFormat: DateFormatter.TWELVE_HOUR_TIME.rawValue))"
            break
        case "THIS WEEK":
            relevantDateString = DateUtilities.dateString(eventDate, dateFormat: "\(DateFormatter.WEEKDAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
            break
        case "NEXT WEEK":
            relevantDateString = DateUtilities.dateString(eventDate, dateFormat: "\(DateFormatter.WEEKDAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
            break
        default:
            break
        }
        
        return relevantDateString
    }
    
    
    //MARK: - User Defaults
    
    fileprivate func getJoinedGamesFromUserDefaults() -> [String] {
        
        var joinedGamesIds: [String] = []
        
        if let joinedGames = UserDefaults.standard.object(forKey: "userJoinedGamesById") as? NSArray {
            let gameIdArray = joinedGames.mutableCopy()
            joinedGamesIds = gameIdArray as! [String]
            
        } else {
            //TODO: Display that there are no joined games
        }
        
        return joinedGamesIds
    }
    

    
     //MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SEGUE_SHOW_GAME_DETAILS {
            
            let gameDetailsViewController = segue.destination as! GameDetailsViewController
            var game: Game
            
            if let indexPath = tableGameList.indexPathForSelectedRow {
                if indexPath.section == 0 && sectionTitles[0] == "Created Games" {
                    guard createdGames.count >= indexPath.row + 1 else { return }
                    game = createdGames[indexPath.row]
                } else if indexPath.section == 1 || sectionTitles[0] == "Joined Games" {
                    guard joinedGames.count >= indexPath.row + 1 else { return }
                    game = joinedGames[indexPath.row]
                } else {
                    return
                }
            } else {
                game = self.newGame!
            }
            
            gameDetailsViewController.game = game
            gameDetailsViewController.gameTypes = self.gameTypes
            
            if game.userIsOwner == true {
                gameDetailsViewController.userStatus = .user_OWNED
            } else if game.userJoined == true {
                gameDetailsViewController.userStatus = .user_JOINED
            } else {
                gameDetailsViewController.userStatus = .user_NOT_JOINED
            }
            
            gameDetailsViewController.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == SEGUE_SHOW_NEW_GAME {
            
            let navigationController = segue.destination as! UINavigationController
            let newGameTableViewController = navigationController.viewControllers.first as! NewGameTableViewController
            newGameTableViewController.dismissalDelegate = self
            newGameTableViewController.gameTypes = self.gameTypes
            
        }

    }
    

}
