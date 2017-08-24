//
//  GameListViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/16/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import CoreLocation

var loadedGames: [Game] = [] {
    didSet {
        let notification = Notification(name: Notification.Name(rawValue: "loadedGames"))
        NotificationCenter.default.post(notification)
    }
}

class GameListViewController: UIViewController, UITableViewDelegate, CLLocationManagerDelegate, DismissalDelegate {
    
    let SEGUE_SHOW_GAME_DETAILS = "showGameDetailsViewController"
    let SEGUE_SHOW_GAMES_MAP = "showGamesMapView"
    let SEGUE_SHOW_NEW_GAME = "showNewGameTableViewController"
    
    var sectionTitles:[String] = []
    
    let METERS_IN_MILE = 1609.34
    let METERS_IN_KILOMETER = 1000.0
    
    var selectedGameType: GameType?
    var gameTypes: [GameType]!
    var games: [Game] = []
    var sortedGames: [Game] = []
    var newGame: Game?
    var currentLocation: CLLocation?
    
    @IBOutlet weak var btnAddNewGame: UIBarButtonItem!
    @IBOutlet weak var tableGameList: UITableView!
    @IBOutlet weak var btnViewMap: UIBarButtonItem!
    @IBOutlet weak var noGamesBlur: UIVisualEffectView!
    @IBOutlet weak var lblNoGames: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    //https://www.andrewcbancroft.com/2015/03/17/basics-of-pull-to-refresh-for-swift-developers/
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(self.loadGames), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    //MARK: - View Lifecycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        OverallLocation.manager.delegate = self
        
        activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        tableGameList.tableFooterView = UIView(frame: CGRect.zero)
        self.tableGameList.addSubview(self.refreshControl)
        
        lblNoGames.text = "No \(selectedGameType?.name ?? "") games within \(Settings.shared.gameDistance) \(Settings.shared.distanceUnit)"
        
        setUsersCurrentLocation()
        
        self.title = selectedGameType?.displayName
        
        btnViewMap.tintColor = Theme.ACCENT_COLOR
        btnAddNewGame.tintColor = Theme.ACCENT_COLOR
        
        self.loadGames()
        
    }
    
    func loadGames() {
        GameController.shared.loadGames(of: selectedGameType!) { (games) in
            DispatchQueue.main.async {
                self.games = games
                loadedGames = games
                self.sort(games)
                self.blurScreenIfNeeded()
                self.tableGameList.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func sort(_ games: [Game]?) {
        
        guard let gamesToSort = games else { return }

        var sortedGames: [Game] = []
        
        if games != nil {
            sortedGames = gamesToSort.filter { $0.gameType.name == (self.selectedGameType?.name) }
        }
        
        if Settings.shared.showCreatedGames == false {
            sortedGames = sortedGames.filter { $0.ownerId != currentPlayer.id }
        }
        
//        OverallLocation.manager.requestLocation()
//        currentLocation = OverallLocation.manager.location
//        
//        if Settings.shared.distanceUnit == DistanceUnit.KILOMETERS.rawValue {
//            
//            guard currentLocation != nil else { self.sortedGames = sortedGames; return }
//            let gameDistance = Double(Settings.shared.gameDistance)
//            let filteredGamesByDistance = sortedGames.filter { $0.latitude.distance(to: (currentLocation?.coordinate.latitude)!) <= gameDistance * 1.60934 && $0.longitude.distance(to: (currentLocation?.coordinate.longitude)!) <= gameDistance * 1.60934 }
//            sortedGames = filteredGamesByDistance
//            
//        } else {
//            
//            let gameDistance = Double(Settings.shared.gameDistance)
//            guard currentLocation != nil else { self.sortedGames = sortedGames; return }
//            let filteredGamesByDistance = sortedGames.filter { $0.latitude.distance(to: (currentLocation?.coordinate.latitude)!) <= gameDistance && $0.longitude.distance(to: (currentLocation?.coordinate.longitude)!) <= gameDistance }
//            sortedGames = filteredGamesByDistance
//         }

        self.sortedGames = sortedGames
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let gameType = selectedGameType {
            GameController.shared.loadGames(of: gameType) { (games) in
                self.sort(games)
            }
        }
        self.blurScreenIfNeeded()
        self.tableGameList.reloadData()
    }
    
    fileprivate func blurScreenIfNeeded() {
        if sortedGames.count == 0 {
            noGamesBlur.isHidden = false
        } else {
            noGamesBlur.isHidden = true
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true

        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedGames.count
    }
    
    
    private func tableView(_ tableView : UITableView,  titleForHeaderInSection section: Int)->String {
        var sectionTitle = ""
        
        if !sectionTitles.isEmpty {
            sectionTitle = sectionTitles[section]
        }
        
        return sectionTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedGames.count
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
    }
    
    
    //MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> GameTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? GameTableViewCell
        
        if !self.games.isEmpty {
            
            let game = sortedGames[indexPath.row]
            
            cell?.lblLocationName.text = game.locationName
            cell?.lblGameDate.text = relevantDateInfo(game.eventDate)
            cell?.lblDistance.text = ""
            
            if game.userJoined == true {
                if game.userIsOwner == true {
                    cell?.imgCheckCircle.image = UIImage(named: "ownerIcon")
                    cell?.lblJoined.text = "Creator"
                } else {
                    cell?.imgCheckCircle.image = UIImage(named: "checkIcon")
                    cell?.lblJoined.text = "Joined"
                }
                cell?.lblJoined.isHidden = false
                cell?.imgCheckCircle.isHidden = false
            } else {
                cell?.lblJoined.isHidden = true
                cell?.imgCheckCircle.isHidden = true
            }
            
            let latitude:CLLocationDegrees = game.latitude
            let longitude:CLLocationDegrees = game.longitude
            let gameLocation:CLLocation = CLLocation(latitude: latitude, longitude: longitude)
            if self.currentLocation != nil && Settings.shared.defaultLocation == "none" {
                let distance:Double = getDistanceBetweenLocations(gameLocation, location2: self.currentLocation!)
                var suffix = "mi"
                if Settings.shared.distanceUnit == "kilometers" {
                    suffix = "km"
                }
                cell?.lblDistance.text = "\(distance) \(suffix)"
                
            } else {
                let distance:Double = getDistanceBetweenLocations(gameLocation, location2: CLLocation(latitude: Settings.shared.defaultLatitude, longitude: Settings.shared.defaultLongitude))
                var suffix = "mi"
                if Settings.shared.distanceUnit == "kilometers" {
                    suffix = "km"
                }
                cell?.lblDistance.text = "\(distance) \(suffix)"
            }
        } else {
            blurScreenIfNeeded()
        }
        
        return cell!
    }
    
    /*
     func loadGamesFromParse() {
     let gameQuery = PFQuery(className: "Game")
     
     //        gameQuery.whereKey("gameType", equalTo: PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id))
     
     gameQuery.whereKey("gameType", equalTo: PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id))
     
     var userGeoPoint = PFGeoPoint(latitude: Settings.sharedSettings.defaultLatitude, longitude: Settings.sharedSettings.defaultLongitude)
     
     if Settings.sharedSettings.defaultLocation == "none" && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
     userGeoPoint = PFGeoPoint(latitude: (self.currentLocation?.coordinate.latitude)!, longitude: self.currentLocation!.coordinate.longitude)
     }
     
     //        gameQuery.whereKey("gameType", equalTo: PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id))
     gameQuery.whereKey("gameType", equalTo: PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id))
     
     if Settings.sharedSettings.distanceUnit == "miles" {
     let gameDistance = Double(Settings.sharedSettings.gameDistance)
     gameQuery.whereKey("location", nearGeoPoint:userGeoPoint, withinMiles:gameDistance)
     } else {
     let gameDistance = Double(Settings.sharedSettings.gameDistance)
     gameQuery.whereKey("location", nearGeoPoint:userGeoPoint, withinKilometers:gameDistance)
     }
     
     gameQuery.whereKey("date", greaterThanOrEqualTo: Date().addingTimeInterval(-1.5 * 60 * 60))
     gameQuery.whereKey("date", lessThanOrEqualTo: Date().addingTimeInterval(2 * 7 * 24 * 60 * 60))
     gameQuery.whereKey("isCancelled", equalTo: false)
     gameQuery.whereKey("slotsAvailable", greaterThanOrEqualTo: 1)
     
     if Settings.sharedSettings.showCreatedGames == false {
     gameQuery.whereKey("owner", notEqualTo: PFUser.current()!)
     }
     
     gameQuery.findObjectsInBackground { (objects, error) -> Void in
     DispatchQueue.main.async {
     if let gameObjects = objects {
     self.games.removeAll(keepingCapacity: true)
     for gameObject in gameObjects {
     let game = GameConverter.convertParseObject(gameObject, selectedGameType: self.selectedGameType)
     
     if (gameObject["owner"] as AnyObject).objectId == PFUser.current()?.objectId {
     game.userIsOwner = true
     }
     
     if let joinedGames = UserDefaults.standard.object(forKey: "userJoinedGamesById") as? NSArray {
     if joinedGames.contains(game.id) {
     game.userJoined = true
     }
     }
     self.games.append(game)
     }
     } else {
     print(error ?? "Error finding objects in background")
     }
     
     if self.games.count == 0 {
     self.blurScreen()
     } else {
     self.sortedGames = self.sortGamesByDate(self.games)
     self.refreshControl.endRefreshing()
     self.activityIndicator.stopAnimating()
     self.activityIndicator.isHidden = true
     self.tableGameList.reloadData()
     }
     }
     }
     }
     
     */
    
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
        OverallLocation.manager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            OverallLocation.manager.delegate = self
            OverallLocation.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            OverallLocation.manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
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
    
    
    //MARK: - Sort Dates
    //TODO: Abstract date functions into separate class
    func sortGamesByDate(_ games: [Game]) -> [[Game]] {
        
        var todayGames:[Game] = []
        var tomorrowGames:[Game] = []
        var thisWeekGames:[Game] = []
        var nextWeekGames:[Game] = []
        var combinedGamesArray:[[Game]] = [[]]
        
        //Sort the games with earliest game first
        //TODO: This won't work on a new year
        let sortedGameArray = games.sorted { (gameOne, gameTwo) -> Bool in
            let firstElementDay = (Calendar.current as NSCalendar).ordinality(of: .day, in: .year, for: gameOne.eventDate as Date)
            let secondElementDay = (Calendar.current as NSCalendar).ordinality(of: .day, in: .year, for: gameTwo.eventDate as Date)
            
            return firstElementDay < secondElementDay
        }
        
        for game in sortedGameArray {
            switch(dateCompare(game.eventDate as Date)) {
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
    
    func relevantDateInfo(_ eventDate: Date) -> String {
        
        var relevantDateString = ""
        
        switch(dateCompare(eventDate)) {
        case "TODAY":
            relevantDateString = DateUtilities.dateString(eventDate, dateFormat: DateFormatter.TWELVE_HOUR_TIME.rawValue)
            break
        case "TOMORROW":
            relevantDateString = DateUtilities.dateString(eventDate, dateFormat: DateFormatter.TWELVE_HOUR_TIME.rawValue)
            break
        case "THIS WEEK":
            relevantDateString = DateUtilities.dateString(eventDate, dateFormat: "\(DateFormatter.WEEKDAY.rawValue) \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
            break
        case "NEXT WEEK":
            relevantDateString = DateUtilities.dateString(eventDate, dateFormat: "\(DateFormatter.WEEKDAY.rawValue) \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
            break
        default:
            break
        }
        
        return relevantDateString
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_SHOW_GAME_DETAILS {
            
            let gameDetailsViewController = segue.destination as! GameDetailsViewController
            var game: Game
            
            if let indexPath = tableGameList.indexPathForSelectedRow {
                game = sortedGames[indexPath.row]
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
            
        } else if segue.identifier == SEGUE_SHOW_GAMES_MAP {
            
            let gameMapViewController = segue.destination as! GameMapViewController
            gameMapViewController.games = self.games
            gameMapViewController.selectedGameType = self.selectedGameType
            
        } else if segue.identifier == SEGUE_SHOW_NEW_GAME {
            
            let navigationController = segue.destination as! UINavigationController
            let newGameTableViewController = navigationController.viewControllers.first as! NewGameTableViewController
            newGameTableViewController.dismissalDelegate = self
            newGameTableViewController.gameTypes = self.gameTypes
            newGameTableViewController.selectedGameType = self.selectedGameType
        }
        
    }
    
}
