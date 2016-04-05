//
//  HomeTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/8/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class HomeTableViewController: UITableViewController, CLLocationManagerDelegate, DismissalDelegate {
    
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
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation? {
        didSet {
            loadGameCounts()
        }
    }
    
    @IBOutlet weak var refresher: UIRefreshControl!
    @IBOutlet weak var addNewGameButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    lazy var activityIndicator: UIActivityIndicatorView! = {
        let activityIndicator = UIActivityIndicatorView()

        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeTableViewController.loadGameFromParseWithSegue(_:)), name: "com.pickup.loadGameFromNotificationWithSegue", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeTableViewController.loadGameFromParseWithAlert(_:)), name: "com.pickup.loadGameFromNotificationWithAlert", object: nil)

        refresher.addTarget(self, action: #selector(HomeTableViewController.loadGameCounts), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        self.tableView.addSubview(activityIndicator)

        _ = GameTypeList.sharedGameTypes
        
        let gameTypePullTimeStamp: NSDate = getLastGameTypePull()
        
        if gameTypePullTimeStamp.compare(NSDate().dateByAddingTimeInterval(-24*60*60)) == NSComparisonResult.OrderedAscending {
            loadGameTypesFromParse()
        } else {
            loadGameTypesFromUserDefaults()
        }
        
        addNewGameButton.tintColor = Theme.ACCENT_COLOR
        settingsButton.tintColor = Theme.PRIMARY_LIGHT_COLOR
        self.navigationController!.navigationBar.tintColor = Theme.PRIMARY_LIGHT_COLOR
        
        setUsersCurrentLocation()
    }
    
 
    func setActivityIndicatorProperties() {
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = .Gray
        activityIndicator.tintColor = Theme.PRIMARY_DARK_COLOR
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }

    override func viewDidAppear(animated: Bool) {
        if currentLocation != nil {
            loadGameCounts()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameTypes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> HomeTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? HomeTableViewCell

        let gameType = gameTypes[indexPath.row]
        
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Theme.GAME_TYPE_CELL_HEIGHT
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SEGUE_SHOW_GAMES, sender: self)
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
        
        GameTypeList.sharedGameTypes.setGameTypeList(self.gameTypes)
        activityIndicator.stopAnimating()
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
    
    private func loadGameTypesFromParse() {
        
        let gameTypeQuery = PFQuery(className: "GameType")
        gameTypeQuery.orderByAscending("sortOrder")
        gameTypeQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let gameTypeObjects = objects {
    
                self.gameTypes.removeAll(keepCapacity: true)
                
                for gameTypeObject in gameTypeObjects {
                    let gameType = GameTypeConverter.convertParseObject(gameTypeObject)
                    self.gameTypes.append(gameType)
                }
            }
            
            self.saveGameTypesToUserDefaults()
            GameTypeList.sharedGameTypes.setGameTypeList(self.gameTypes)
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    
    func loadGameCounts() {
        
        for gameType in self.gameTypes {
            let gameTypeObject = PFObject(outDataWithClassName: "GameType", objectId: gameType.id)
            let gameQuery = PFQuery(className: "Game")
            gameQuery.whereKey("gameType", equalTo: gameTypeObject)
            gameQuery.whereKey("date", greaterThanOrEqualTo: NSDate().dateByAddingTimeInterval(-1.5 * 60 * 60))
            gameQuery.whereKey("date", lessThanOrEqualTo: NSDate().dateByAddingTimeInterval(2 * 7 * 24 * 60 * 60))
            gameQuery.whereKey("isCancelled", equalTo: false)
            gameQuery.whereKey("slotsAvailable", greaterThanOrEqualTo: 1)
            
            if Settings.sharedSettings.showCreatedGames == false {
                gameQuery.whereKey("owner", notEqualTo: PFUser.currentUser()!)
            }
            
            let userGeoPoint = PFGeoPoint(latitude: (self.currentLocation?.coordinate.latitude)!, longitude: self.currentLocation!.coordinate.longitude)
            
            if Settings.sharedSettings.distanceUnit == "miles" {
                let gameDistance = Double(Settings.sharedSettings.gameDistance)
                gameQuery.whereKey("location", nearGeoPoint:userGeoPoint, withinMiles:gameDistance)
            } else {
                let gameDistance = Double(Settings.sharedSettings.gameDistance)
                gameQuery.whereKey("location", nearGeoPoint:userGeoPoint, withinKilometers:gameDistance)
            }

            gameQuery.countObjectsInBackgroundWithBlock({ (count: Int32, error: NSError?) -> Void in
                    let gameCount = Int(count)
                    gameType.setGameCount(gameCount)
                    self.gameCountLoaded = true
            })
            
            refresher.endRefreshing()
        }
    }
    
    func loadGameFromParseWithSegue(notification: NSNotification) {
        loadGameFromParse(false, notification: notification)
    }
    
    func loadGameFromParseWithAlert(notification: NSNotification) {
        loadGameFromParse(true, notification: notification)
    }
    
    func loadGameFromParse(showAlert: Bool, notification: NSNotification) {
        
        let gameId = notification.userInfo!["selectedGameId"]
        let gameQuery = PFQuery(className: "Game")
        gameQuery.whereKey("objectId", equalTo: gameId!)
        
        gameQuery.getFirstObjectInBackgroundWithBlock {
            (game: PFObject?, error: NSError?) -> Void in
            if error != nil || game == nil {
                print("Home table view controller")
                print("The getFirstObject on Game request failed.")
            } else {
                
                self.gameTypes = GameTypeList.sharedGameTypes.gameTypeList
                let gameTypeId = game?["gameType"].objectId!
                
                self.newGame = GameConverter.convertParseObject(game!, selectedGameType: GameTypeList.sharedGameTypes.getGameTypeById(gameTypeId!)!)
                
                if game?["owner"].objectId! == PFUser.currentUser()?.objectId! {
                    self.newGame.userIsOwner = true
                }

                self.newGame.userJoined = true
                
                if showAlert == true {
                    self.showAlert(notification)
                } else {
                    self.performSegueWithIdentifier(self.SEGUE_SHOW_GAME_DETAILS, sender: self)
                }
            }
        }
    }
    
    //MARK: - Notification Alert
    private func showAlert(notification: NSNotification) {
        let notificationMessage = notification.userInfo!["alertBody"]
        let message: String = notificationMessage as! String
        
        let alertConfirmationTitle = "View Game"
        let alertCancelTitle = "Ignore"
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: alertCancelTitle, style: UIAlertActionStyle.Default,handler: nil))
        alertController.addAction(UIAlertAction(title: alertConfirmationTitle, style: UIAlertActionStyle.Default, handler: { action in
            self.performSegueWithIdentifier(self.SEGUE_SHOW_GAME_DETAILS, sender: self)
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Location Manager Delegate

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
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
    
    // MARK: - Dismissal Delegate
    
    func finishedShowing(viewController: UIViewController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier(SEGUE_SHOW_GAME_DETAILS, sender: self)
        
        return
    }
    
    func setNewGame(game: Game) {
        self.newGame = game
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SHOW_GAMES {
            let gamesViewController = segue.destinationViewController as! GameListViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                gamesViewController.selectedGameType = gameTypes[indexPath.row]
                gamesViewController.gameTypes = self.gameTypes
            }
            gamesViewController.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == SEGUE_SHOW_NEW_GAME {
            let navigationController = segue.destinationViewController as! UINavigationController
            let newGameTableViewController = navigationController.viewControllers.first as! NewGameTableViewController
            newGameTableViewController.dismissalDelegate = self
            newGameTableViewController.gameTypes = self.gameTypes
        } else if segue.identifier == SEGUE_SHOW_MY_GAMES {
            let myGamesViewController = segue.destinationViewController as! MyGamesViewController
            myGamesViewController.gameTypes = self.gameTypes
        } else if segue.identifier == SEGUE_SHOW_GAME_DETAILS {
            let gameDetailsViewController = segue.destinationViewController as! GameDetailsViewController
            
            if self.newGame.userIsOwner == true {
                gameDetailsViewController.userStatus = .USER_OWNED
            } else {
                gameDetailsViewController.userStatus = .USER_JOINED
            }
            
            gameDetailsViewController.game = self.newGame
        
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


}
