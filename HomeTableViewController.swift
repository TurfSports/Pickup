//
//  HomeTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/8/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FBSDKLoginKit

var loadedGameTypes: [GameType] = []
var facebookLoginManager = FBSDKLoginManager.init()

class HomeTableViewController: UITableViewController, DismissalDelegate, CLLocationManagerDelegate {
    
    let SEGUE_SHOW_GAMES = "showGamesTableViewController"
    let SEGUE_SHOW_NEW_GAME = "showNewGameTableViewController"
    let SEGUE_SHOW_MY_GAMES = "showMyGamesViewController"
    let SEGUE_SHOW_GAME_DETAILS = "showGameDetailsViewController"
    
    var newGame: Game!
    var gameTypes:[GameType] = []
    var gameCountLoaded:Bool = false {
        didSet {
            self.tableView.reloadData()
        }
    }

    var currentLocation: CLLocation? {
        didSet {
            // Load Game Counts
        }
    }
    
    
    
    @IBOutlet weak var refresher: UIRefreshControl!
    @IBOutlet weak var addNewGameButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    lazy var activityIndicator: UIActivityIndicatorView! = {
        let activityIndicator = UIActivityIndicatorView()
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        return activityIndicator
    }()
    
    func loadGameTypes() {
        GameTypeController.shared.loadGameTypes { (gameTypes) in
            self.gameTypes = gameTypes
        }
        refreshControl?.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let facebookAccessToken = FBSDKAccessToken.current()
        
        if facebookAccessToken == nil {
            self.performSegue(withIdentifier: "toLoginView", sender: self)
        } else {
            print("Already logged in")
        }
        
        loadGameTypes()
        
        OverallLocation.manager.delegate = self
        
        ////      iOS 9.2
        //      NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadGameFromParseWithSegue:", name: "com.pickup.loadGameFromNotificationWithSegue", object: nil)
        //      NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadGameFromParseWithAlert:", name: "com.pickup.loadGameFromNotificationWithAlert", object: nil)
        //
        //      iOS 9.3
        // Add load games with segue and alert
        //        NotificationCenter.default.addObserver(self, selector: #selector(HomeTableViewController.loadGamesFromParseWithSegue(_:)), name: NSNotification.Name(rawValue: "com.pickup.loadGameFromNotificationWithSegue"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(HomeTableViewController.loadGameFromParseWithAlert(_:)), name: NSNotification.Name(rawValue: "com.pickup.loadGameFromNotificationWithAlert"), object: nil)
        
        //        refresher.addTarget(self, action: "loadGameCounts", forControlEvents: UIControlEvents.ValueChanged)
        //        refresher.addTarget(self, action: #selector(HomeTableViewController.loadGameCounts), for: UIControlEvents.valueChanged)
        
        self.tableView.addSubview(refresher)
        self.tableView.addSubview(activityIndicator)
        
        _ = GameTypeList.shared
        
        let gameTypePullTimeStamp: Date = getLastGameTypePull()
        
        if gameTypePullTimeStamp.compare(Date().addingTimeInterval(-24*60*60)) == ComparisonResult.orderedAscending {
            GameTypeController.shared.loadGameTypes() { (gameTypeArray) in
                self.gameTypes = gameTypeArray
                loadedGameTypes = gameTypeArray
                self.tableView.reloadData()
            }
        } else {
            loadGameTypesFromUserDefaults()
        }
        
        FirebaseController.shared.getGameTypeImages { (gotImages) in
            if gotImages {
                print("Got images")
            } else {
                
            }
        }
        
        addNewGameButton.tintColor = Theme.ACCENT_COLOR
        settingsButton.tintColor = Theme.PRIMARY_LIGHT_COLOR
        self.navigationController!.navigationBar.tintColor = Theme.PRIMARY_LIGHT_COLOR
        
        setUsersCurrentLocation()
    }
    
    
    func setActivityIndicatorProperties() {
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.tintColor = Theme.PRIMARY_DARK_COLOR
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if currentLocation != nil {
            //            loadGameCounts()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> HomeTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? HomeTableViewCell
        
        let gameType = gameTypes[(indexPath as NSIndexPath).row]
        
        if UIImage(named: gameType.imageName) == nil {
            var imageName = gameType.imageName.lowercased()
            let chars = imageName.characters
            let realChars = chars.dropLast(4)
            gameType.imageName = String.init(realChars) + "Icon"
        }
        
        cell?.lblSport.text = gameType.displayName
        cell?.imgSport.image = UIImage(named: gameType.imageName)
        
        if self.gameCountLoaded {
            if gameType.gameCount > 0 {
                cell?.lblAvailableGames.text = "\(gameType.gameCount) games"
            } else {
                cell?.lblAvailableGames.text = "No games"
            }
        } else {
            cell?.lblAvailableGames.text = ""
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.GAME_TYPE_CELL_HEIGHT
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SEGUE_SHOW_GAMES, sender: self)
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
    
    //MARK: - Parse
    
    /*
     
     fileprivate func loadGameTypesFromParse() {
     
     let gameTypeQuery = PFQuery(className: "GameType")
     gameTypeQuery.order(byAscending: "sortOrder")
     gameTypeQuery.findObjectsInBackground { (objects, error) -> Void in
     if let gameTypeObjects = objects {
     
     self.gameTypes.removeAll(keepingCapacity: true)
     
     for gameTypeObject in gameTypeObjects {
     let gameType = GameTypeConverter.convertParseObject(gameTypeObject)
     self.gameTypes.append(gameType)
     }
     }
     
     self.saveGameTypesToUserDefaults()
     GameTypeList.sharedGameTypes.setGameTypeList(self.gameTypes)
     self.activityIndicator.stopAnimating()
     DispatchQueue.main.async {
     self.tableView.reloadData()
     }
     }
     }
     
     
     func loadGameCounts() {
     
     for gameType in self.gameTypes {
     //            let gameTypeObject = PFObject(withoutDataWithClassName: "GameType", objectId: gameType.id)
     let gameTypeObject = PFObject(withoutDataWithClassName: "GameType", objectId: gameType.id)
     
     let gameQuery = PFQuery(className: "Game")
     gameQuery.whereKey("gameType", equalTo: gameTypeObject)
     gameQuery.whereKey("date", greaterThanOrEqualTo: Date().addingTimeInterval(-1.5 * 60 * 60))
     gameQuery.whereKey("date", lessThanOrEqualTo: Date().addingTimeInterval(2 * 7 * 24 * 60 * 60))
     gameQuery.whereKey("isCancelled", equalTo: false)
     gameQuery.whereKey("slotsAvailable", greaterThanOrEqualTo: 1)
     
     if Settings.sharedSettings.showCreatedGames == false {
     gameQuery.whereKey("owner", notEqualTo: PFUser.current()!)
     }
     
     var userGeoPoint = PFGeoPoint(latitude: Settings.sharedSettings.defaultLatitude, longitude: Settings.sharedSettings.defaultLongitude)
     
     if Settings.sharedSettings.defaultLocation == "none" && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
     userGeoPoint = PFGeoPoint(latitude: (self.currentLocation?.coordinate.latitude)!, longitude: self.currentLocation!.coordinate.longitude)
     }
     
     if Settings.sharedSettings.distanceUnit == "miles" {
     let gameDistance = Double(Settings.sharedSettings.gameDistance)
     gameQuery.whereKey("location", nearGeoPoint:userGeoPoint, withinMiles:gameDistance)
     } else {
     let gameDistance = Double(Settings.sharedSettings.gameDistance)
     gameQuery.whereKey("location", nearGeoPoint:userGeoPoint, withinKilometers:gameDistance)
     }
     
     gameQuery.countObjectsInBackground(block: { (count: Int32, error: Error?) -> Void in
     let gameCount = Int(count)
     gameType.setGameCount(gameCount)
     DispatchQueue.main.async {
     self.gameCountLoaded = true
     }
     })
     
     refresher.endRefreshing()
     }
     }
     
     func loadGameFromParseWithSegue(_ notification: Notification) {
     loadGameFromParse(false, notification: notification)
     }
     
     func loadGameFromParseWithAlert(_ notification: Notification) {
     loadGameFromParse(true, notification: notification)
     }
     
     func loadGameFromParse(_ showAlert: Bool, notification: Notification) {
     
     let gameId = (notification as NSNotification).userInfo!["selectedGameId"]
     let gameQuery = PFQuery(className: "Game")
     gameQuery.whereKey("objectId", equalTo: gameId!)
     
     gameQuery.getFirstObjectInBackground {
     (game: PFObject?, error: Error?) -> Void in
     if error != nil || game == nil {
     print("Home table view controller")
     print("The getFirstObject on Game request failed.")
     } else {
     
     self.gameTypes = GameTypeList.sharedGameTypes.gameTypeList
     let gameTypeId = (game?["gameType"] as AnyObject).objectId!
     
     self.newGame = GameConverter.convertParseObject(game!, selectedGameType: GameTypeList.sharedGameTypes.getGameTypeById(gameTypeId!)!)
     
     if (game?["owner"] as AnyObject).objectId! == PFUser.current()?.objectId! {
     self.newGame.userIsOwner = true
     }
     
     self.newGame.userJoined = true
     
     DispatchQueue.main.async {
     if showAlert == true {
     self.showAlert(notification)
     } else {
     self.performSegue(withIdentifier: self.SEGUE_SHOW_GAME_DETAILS, sender: self)
     }
     }
     }
     }
     }
     */
    
    //MARK: - Notification Alert
    
    fileprivate func showAlert(_ notification: Notification) {
        let notificationMessage = (notification as NSNotification).userInfo!["alertBody"]
        let message: String = notificationMessage as! String
        
        let alertConfirmationTitle = "View Game"
        let alertCancelTitle = "Ignore"
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: alertCancelTitle, style: UIAlertActionStyle.default,handler: nil))
        alertController.addAction(UIAlertAction(title: alertConfirmationTitle, style: UIAlertActionStyle.default, handler: { action in
            self.performSegue(withIdentifier: self.SEGUE_SHOW_GAME_DETAILS, sender: self)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        print(location)
        currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        if currentLocation != nil {
            manager.stopUpdatingLocation()
        }
        
        self.tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if (!CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() != .authorizedWhenInUse) && Settings.shared.defaultLocation == "none" {
            getZipCodeFromUserWithAlert()
        }
        
    }
    
    func getZipCodeFromUserWithAlert() {
        
        //http://stackoverflow.com/questions/26567413/get-input-value-from-textfield-in-ios-alert-in-swift
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Static Location", message: "You have disabled location services for this app. Please enter a zip code to see local games.", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.keyboardType = UIKeyboardType.numberPad
            
            //            textField.addTarget(self, action: "textChanged:", forControlEvents: UIControlEvents.EditingChanged)
            textField.addTarget(self, action: #selector(HomeTableViewController.textChanged(_:)), for: .editingChanged)
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            guard let text = textField.text else { print("Text field: nil"); return }
            print("Text field: \(text)")
        }))
        
        (alert.actions[0] as UIAlertAction).isEnabled = false
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func textChanged(_ sender:AnyObject) {
        let textField = sender as! UITextField
        var responder: UIResponder = textField
        while !(responder is UIAlertController) { responder = responder.next! }
        let alert = responder as! UIAlertController
        
        if textField.text?.characters.count == 5 {
            validateZipCode(textField.text!, alert: alert)
        }
        
    }
    
    func validateZipCode(_ zipcode: String, alert: UIAlertController) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(zipcode, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error ?? "Error Validating ZipCode")
            } else if let placemark = placemarks?.first {
                
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                if let city = placemark.addressDictionary!["City"] as? NSString {
                    if let country = placemark.addressDictionary!["Country"] as? NSString {
                        if country == "United States" || country == "Canada" {
                            if let state = placemark.addressDictionary!["State"] as? NSString {
                                alert.message = "\(city), \(state)"
                            }
                        } else {
                            alert.message = "\(city), \(country)"
                        }
                        
                    }
                }
                
                (alert.actions[0] as UIAlertAction).isEnabled = true
                
                Settings.shared.defaultLocation = zipcode
                Settings.shared.defaultLatitude = coordinates.latitude
                Settings.shared.defaultLongitude = coordinates.longitude
            }
        })
        
        
    }
    
    func setUsersCurrentLocation() {
        OverallLocation.manager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            OverallLocation.manager.delegate = self
            OverallLocation.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            OverallLocation.manager.startUpdatingLocation()
        }
    }
    
    // MARK: - Dismissal Delegate
    
    func finishedShowing(_ viewController: UIViewController) {
        
        self.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: SEGUE_SHOW_GAME_DETAILS, sender: self)
        
        return
    }
    
    func setNewGame(_ game: Game) {
        self.newGame = game
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_SHOW_GAMES {
            let gamesViewController = segue.destination as! GameListViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                gamesViewController.selectedGameType = gameTypes[indexPath.row]
                gamesViewController.gameTypes = self.gameTypes
            }
            gamesViewController.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == SEGUE_SHOW_NEW_GAME {
            let navigationController = segue.destination as! UINavigationController
            let newGameTableViewController = navigationController.viewControllers.first as! NewGameTableViewController
            newGameTableViewController.dismissalDelegate = self
            newGameTableViewController.gameTypes = self.gameTypes
        } else if segue.identifier == SEGUE_SHOW_MY_GAMES {
            let myGamesViewController = segue.destination as! MyGamesViewController
            myGamesViewController.gameTypes = self.gameTypes
        } else if segue.identifier == SEGUE_SHOW_GAME_DETAILS {
            let gameDetailsViewController = segue.destination as! GameDetailsViewController
            
            if self.newGame.userIsOwner == true {
                gameDetailsViewController.userStatus = .user_OWNED
            } else {
                gameDetailsViewController.userStatus = .user_JOINED
            }
            
            gameDetailsViewController.game = self.newGame
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}
