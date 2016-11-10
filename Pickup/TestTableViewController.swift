//
//  TestTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 11/1/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class TestTableViewController: UITableViewController, CLLocationManagerDelegate {

    var selectedGameType:GameType!
    var gameTypes:[GameType]!
    var games: [Game] = []
    var sortedGames: [[Game]]! = [[]]
    
    var sectionTitles:[String] = []
    
    let METERS_IN_MILE = 1609.34
    let METERS_IN_KILOMETER = 1000.0
    
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation? {
        didSet {
            loadGamesFromParse()
        }
    }
    
    @IBOutlet weak var lblLocation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUsersCurrentLocation()
        
//        btnViewMap.tintColor = Theme.ACCENT_COLOR
//        btnAddNewGame.tintColor = Theme.ACCENT_COLOR
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sortedGames.count
    }
    
    override func tableView(_ tableView : UITableView,  titleForHeaderInSection section: Int)->String {
        var sectionTitle = ""
        
        if !sectionTitles.isEmpty {
            sectionTitle = sectionTitles[section]
        }
        
        return sectionTitle
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = Theme.PRIMARY_DARK_COLOR
        header.textLabel?.textAlignment = .center
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sortedGamesSectionCount = sortedGames[section].count
        print("SortedGames: \(sortedGamesSectionCount)")
        
        return sortedGames[section].count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> GameTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? GameTableViewCell
        
        if !sortedGames.isEmpty {
            
            let game = sortedGames[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
            cell?.lblGameDate.text = relevantDateInfo(game.eventDate as Date)
            cell?.lblLocationName.text = games[indexPath.row].locationName
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
        
            
            if self.currentLocation != nil && Settings.sharedSettings.defaultLocation == "none" {
                let distance:Double = getDistanceBetweenLocations(gameLocation, location2: self.currentLocation!)
                var suffix = "mi"
                if Settings.sharedSettings.distanceUnit == "kilometers" {
                    suffix = "km"
                }
                cell?.lblDistance.text = "\(distance) \(suffix)"
                
            } else {
                let distance:Double = getDistanceBetweenLocations(gameLocation, location2: CLLocation(latitude: Settings.sharedSettings.defaultLatitude, longitude: Settings.sharedSettings.defaultLongitude))
                var suffix = "mi"
                if Settings.sharedSettings.distanceUnit == "kilometers" {
                    suffix = "km"
                }
                cell?.lblDistance.text = "\(distance) \(suffix)"
            }
        
        } else {
            print("Empty sortedGames array")
        }

    
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.GAME_LIST_ROW_HEIGHT
    }
    
    
    func loadGamesFromParse() {
        let gameQuery = PFQuery(className: "Game")
        
        //        gameQuery.whereKey("gameType", equalTo: PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id))
        gameQuery.whereKey("gameType", equalTo: PFObject(outDataWithClassName: "GameType", objectId: selectedGameType.id))
        
        let userGeoPoint = PFGeoPoint(latitude: Settings.sharedSettings.defaultLatitude, longitude: Settings.sharedSettings.defaultLongitude)
    
        
        //        gameQuery.whereKey("gameType", equalTo: PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id))
        gameQuery.whereKey("gameType", equalTo: PFObject(outDataWithClassName: "GameType", objectId: selectedGameType.id))
        
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
                print(error)
            }
            
            if self.games.count == 0 {
                print("NO GAMES")
            } else {
                self.sortedGames = self.sortGamesByDate(self.games)
                self.tableView.reloadData()
            }
            
        }
    }
    
    //MARK: - Location Manager Delegate
    //TODO: Abstract location methods into their own class
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        if currentLocation != nil {
            locationManager.stopUpdatingLocation()
        }
        
        self.tableView.reloadData()
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
        
        if Settings.sharedSettings.distanceUnit == "miles" {
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


    

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
