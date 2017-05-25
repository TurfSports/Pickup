//
//  GameDetailsViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/1/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import MapKit

class GameDetailsViewController: UIViewController, MKMapViewDelegate, GameDetailsViewDelegate {

    let SEGUE_SHOW_EDIT_GAME = "ShowEditGame"
    let SEGUE_SHOW_EMBEDDED_DETAILS = "showGameDetailsTableViewController"

    @IBOutlet weak var lblLocationName: UILabel!
    @IBOutlet weak var lblOpenings: UILabel!
    @IBOutlet weak var imgGameType: UIImageView!
    @IBOutlet weak var btnJoinGame: UIBarButtonItem!
    
    
    var myGamesTableViewDelegate: MyGamesTableViewDelegate?
    var embeddedView: GameDetailsTableViewController!
    
    let navBarButtonTitleOptions: [UserStatus: String] = [.user_NOT_JOINED: "Join Game", .user_JOINED: "Leave Game", .user_OWNED: "Edit Game"]
    let bottomBarVisible: [UserStatus: Bool] = [.user_NOT_JOINED: false, .user_JOINED: false, .user_OWNED: true]
    let alertAction: [UserStatus: String] = [.user_NOT_JOINED: "join", .user_JOINED: "leave", .user_OWNED: "cancel"]
    let alertTitle: [UserStatus: String] = [.user_NOT_JOINED: "Join", .user_JOINED: "Leave", .user_OWNED: "Yes"]
    let alertCancelTitle: [UserStatus: String] = [.user_NOT_JOINED: "Cancel", .user_JOINED: "Cancel", .user_OWNED: "No"]
    
    var gameTypes: [GameType]!
    var game: Game!
    
    var userStatus: UserStatus = .user_NOT_JOINED
    var address: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnJoinGame.tintColor = Theme.ACCENT_COLOR
        self.navigationController?.navigationBar.tintColor = Theme.PRIMARY_LIGHT_COLOR
        
        if let gameDetailsTableViewController = self.childViewControllers.first as? GameDetailsTableViewController {
        
            if userStatus != .user_NOT_JOINED {
                gameDetailsTableViewController.btnAddToCalendar.isHidden = false
            }
            
            if userStatus == .user_OWNED {
                gameDetailsTableViewController.isOwner = true
            }
        }
        
        lblLocationName.text = game.locationName
        
        lblOpenings.text = ("\(game.availableSlots) openings")
        
        if userStatus == .user_OWNED {
            lblOpenings.text = ("\(game.availableSlots) openings (\(game.totalSlots - game.availableSlots - 1) joined)")
        }
        
        btnJoinGame.title = navBarButtonTitleOptions[userStatus]
        imgGameType.image = UIImage(named: game.gameType.imageName)
        
    }
    
    
    @IBAction func btnJoinGame(_ sender: AnyObject) {
        
        if userStatus == .user_OWNED {
            performSegue(withIdentifier: SEGUE_SHOW_EDIT_GAME, sender: self)
        } else {
            showAlert()
        }
        
    }
    
    //MARK: - Alert
    
    fileprivate func showAlert() {
        let message = "Are you sure you want to \(self.alertAction[userStatus]!) this game?"
        let alertTitle = "\(self.alertTitle[userStatus]!)"
        let alertCancelTitle = "\(self.alertCancelTitle[userStatus]!)"
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: alertCancelTitle, style: UIAlertActionStyle.default, handler: nil))
        alertController.addAction(UIAlertAction(title: alertTitle, style: UIAlertActionStyle.default, handler: { action in
            
            switch(self.userStatus) {
                
            case .user_NOT_JOINED:
                self.joinGame()
                break
            case .user_JOINED:
                self.leaveGame()
                break
            case .user_OWNED:
                break
            }
            
        }))
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: - Joining/Leaving game
    
    fileprivate func joinGame() {
        self.addGameToUserDefaults()
        self.game.availableSlots += -1
        self.game.userJoined = !self.game.userJoined
        self.userStatus = .user_JOINED
        
        LocalNotifications.scheduleGameNotification(self.game)
        
        if !NotificationsManager.notificationsInitiated() {
            NotificationsManager.registerNotifications()
        }
    }
    
    fileprivate func leaveGame() {
        // remove User from game
        
        self.removeGameFromUserDefaults()
        self.game.userJoined = !self.game.userJoined
        self.game.availableSlots += 1
        self.userStatus = .user_NOT_JOINED
        LocalNotifications.cancelGameNotification(self.game)

        
        if myGamesTableViewDelegate != nil {
            myGamesTableViewDelegate?.removeGame(self.game)
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    
    //==========================================================================
    //  MARK: - Firebase
    //==========================================================================
    
    fileprivate func add(_ user: String, to Game: Game) {
        
    }
    
    fileprivate func remove(_ user: String, to Game: Game) {
        
    }
    
    fileprivate func cancel(_ Game: Game) {
        
    }


    
    //MARK: - User Defaults
    
    fileprivate func addGameToUserDefaults() {
        
        if let joinedGames = UserDefaults.standard.object(forKey: "userJoinedGamesById") as? NSArray {
            let gameIdArray = joinedGames.mutableCopy()
            (gameIdArray as AnyObject).add(game.id)
            UserDefaults.standard.set(gameIdArray, forKey: "userJoinedGamesById")
        } else {
            var gameIdArray: [String] = []
            gameIdArray.append(game.id)
            UserDefaults.standard.set(gameIdArray, forKey: "userJoinedGamesById")
        }
        
    }
    
    fileprivate func removeGameFromUserDefaults() {
        
        if let joinedGames = UserDefaults.standard.object(forKey: "userJoinedGamesById") as? NSArray {
            let gameIdArray = joinedGames.mutableCopy()
            (gameIdArray as AnyObject).remove(game.id)
            UserDefaults.standard.set(gameIdArray, forKey: "userJoinedGamesById")
        }
        
    }
    
    //MARK: - Game Details View Delegate
    
    func setGameAddress(_ address: String) {
        self.address = address
        self.embeddedView.lblAddress.text = self.address
    }
    
    func setGame(_ game: Game) {
        self.game = game
        lblLocationName.text = game.locationName
        lblOpenings.text = ("\(game.availableSlots) openings (\(game.totalSlots - game.availableSlots - 1) joined)")
        
        self.embeddedView.lblDay.text = DateUtilities.dateString(self.game.eventDate, dateFormatString: DateFormatter.MONTH_DAY_YEAR.rawValue)
        self.embeddedView.lblTime.text = DateUtilities.dateString(self.game.eventDate, dateFormatString: DateFormatter.TWELVE_HOUR_TIME.rawValue)
        self.embeddedView.lblGameNotes.text = game.gameNotes
        self.embeddedView.game = self.game
        self.embeddedView.tableView.reloadData()
    }
    
    func cancelGame(_ game: Game) {
        showAlert()
    }
    

    
    //MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SEGUE_SHOW_EMBEDDED_DETAILS {
            let embeddedViewController = segue.destination as? GameDetailsTableViewController
            self.embeddedView = embeddedViewController
            embeddedViewController?.game = self.game
            embeddedViewController?.parentDelegate = self
        } else if segue.identifier == SEGUE_SHOW_EDIT_GAME {
            let navigationController = segue.destination as! UINavigationController
            let newGameTableViewController = navigationController.viewControllers.first as! NewGameTableViewController
            
            newGameTableViewController.gameStatus = .edit
            newGameTableViewController.gameDetailsDelegate = self
            newGameTableViewController.gameTypes = self.gameTypes
            newGameTableViewController.game = self.game
            newGameTableViewController.address = self.address
        }
    }
    

    
}
