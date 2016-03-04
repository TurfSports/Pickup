//
//  GameDetailsViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/1/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import Parse
import MapKit

class GameDetailsViewController: UIViewController, MKMapViewDelegate {

    let SEGUE_SHOW_EDIT_GAME = "ShowEditGame"

    @IBOutlet weak var lblLocationName: UILabel!
    @IBOutlet weak var lblOpenings: UILabel!
    @IBOutlet weak var imgGameType: UIImageView!
    @IBOutlet weak var btnJoinGame: UIBarButtonItem!
    
    
    var myGamesTableViewDelegate: MyGamesTableViewDelegate?
    
    let navBarButtonTitleOptions: [UserStatus: String] = [.USER_NOT_JOINED: "Join Game", .USER_JOINED: "Leave Game", .USER_OWNED: "Edit Game"]
    let bottomBarVisible: [UserStatus: Bool] = [.USER_NOT_JOINED: false, .USER_JOINED: false, .USER_OWNED: true]
    let alertAction: [UserStatus: String] = [.USER_NOT_JOINED: "join", .USER_JOINED: "leave", .USER_OWNED: "cancel"]
    let alertTitle: [UserStatus: String] = [.USER_NOT_JOINED: "Join", .USER_JOINED: "Leave", .USER_OWNED: "Yes"]
    let alertCancelTitle: [UserStatus: String] = [.USER_NOT_JOINED: "Cancel", .USER_JOINED: "Cancel", .USER_OWNED: "No"]
    
    var gameTypes: [GameType]!
    var game: Game!
    var userStatus: UserStatus = .USER_NOT_JOINED
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        btnJoinGame.tintColor = Theme.ACCENT_COLOR
        self.navigationController?.navigationBar.tintColor = Theme.PRIMARY_LIGHT_COLOR
        
        if let gameDetailsTableViewController = self.childViewControllers.first as? GameDetailsTableViewController {
        
            if userStatus != .USER_NOT_JOINED {
                gameDetailsTableViewController.btnAddToCalendar.hidden = false
            }
            
            if userStatus == .USER_OWNED {
                gameDetailsTableViewController.isOwner = true
            }
        }
        
        lblLocationName.text = game.locationName
        lblOpenings.text = ("\(game.availableSlots) openings")
        
        btnJoinGame.title = navBarButtonTitleOptions[userStatus]
        imgGameType.image = UIImage(named: game.gameType.imageName)
        
    }
    
    
    @IBAction func btnJoinGame(sender: AnyObject) {
        
        if userStatus == .USER_OWNED {
            
            performSegueWithIdentifier(SEGUE_SHOW_EDIT_GAME, sender: self)
            
        } else {
            let message = "Are you sure you want to \(self.alertAction[userStatus]!) this game?"
            let alertTitle = "\(self.alertTitle[userStatus]!)"
            let alertCancelTitle = "\(self.alertCancelTitle[userStatus]!)"
            
            let alertController = UIAlertController(title: title, message:
                message, preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: alertCancelTitle, style: UIAlertActionStyle.Default,handler: nil))
            alertController.addAction(UIAlertAction(title: alertTitle, style: UIAlertActionStyle.Default, handler: { action in
                
                switch(self.userStatus) {
                    
                case .USER_NOT_JOINED:
                    self.joinGame()
                    break
                case .USER_JOINED:
                    self.leaveGame()
                    break
                default:
                    break
                }
                
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    private func joinGame() {
        self.joinPFUserToPFGame()
        self.addGameToUserDefaults()
        self.game.availableSlots += -1
        self.game.userJoined = !self.game.userJoined
        self.userStatus = .USER_JOINED
        self.viewDidLoad()
    }
    
    private func leaveGame() {
        self.removePFUserFromPFGame()
        self.removeGameFromUserDefaults()
        self.game.userJoined = !self.game.userJoined
        self.game.availableSlots += 1
        self.userStatus = .USER_NOT_JOINED
        
        if myGamesTableViewDelegate != nil {
            myGamesTableViewDelegate?.removeGame(self.game)
            navigationController?.popViewControllerAnimated(true)
        }
        
        self.viewDidLoad()
    }
    
    private func deleteGame() {
        //TODO: Mark game as cancelled
        //Segue back to my games
    }

    
    //MARK: - Parse
    private func joinPFUserToPFGame() {
        let gameQuery = PFQuery(className: "Game")
        gameQuery.whereKey("objectId", equalTo: self.game.id)
        
        gameQuery.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                print("The getFirstObject on Game request failed.")
            } else {
                let currentUser = PFUser.currentUser()
                let gameRelations = object?.relationForKey("players")
                gameRelations?.addObject(currentUser!)
                
                //Decrement slots available
                var slotsAvailable = object?["slotsAvailable"] as! Int
                slotsAvailable += -1
                object?["slotsAvailable"] = slotsAvailable
                
                object?.saveInBackground()
            }
        }
    
    }
    
    private func removePFUserFromPFGame() {
        let gameQuery = PFQuery(className: "Game")
        gameQuery.whereKey("objectId", equalTo: self.game.id)
        
        gameQuery.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                print("The getFirstObject on Game request failed.")
            } else {
                let currentUser = PFUser.currentUser()
                let gameRelations = object?.relationForKey("players")
                gameRelations?.removeObject(currentUser!)
                object?.saveInBackground()
                
                //Increment slots available
                var slotsAvailable = object?["slotsAvailable"] as! Int
                slotsAvailable += 1
                object?["slotsAvailable"] = slotsAvailable
            }
        }
        
    }
    
    //MARK: - User Defaults
    
    private func addGameToUserDefaults() {
        
        if let joinedGames = NSUserDefaults.standardUserDefaults().objectForKey("userJoinedGamesById") as? NSArray {
            let gameIdArray = joinedGames.mutableCopy()
            gameIdArray.addObject(game.id)
            NSUserDefaults.standardUserDefaults().setObject(gameIdArray, forKey: "userJoinedGamesById")
        } else {
            var gameIdArray: [String] = []
            gameIdArray.append(game.id)
            NSUserDefaults.standardUserDefaults().setObject(gameIdArray, forKey: "userJoinedGamesById")
        }
        
    }
    
    private func removeGameFromUserDefaults() {
        
        if let joinedGames = NSUserDefaults.standardUserDefaults().objectForKey("userJoinedGamesById") as? NSArray {
            let gameIdArray = joinedGames.mutableCopy()
            gameIdArray.removeObject(game.id)
            NSUserDefaults.standardUserDefaults().setObject(gameIdArray, forKey: "userJoinedGamesById")
        }
        
    }
    
    //MARK: - Navigation
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let embeddedViewController = segue.destinationViewController as? GameDetailsTableViewController
        embeddedViewController?.game = self.game
        
        if segue.identifier == SEGUE_SHOW_EDIT_GAME {
            let navigationController = segue.destinationViewController as! UINavigationController
            let newGameTableViewController = navigationController.viewControllers.first as! NewGameTableViewController
            
            newGameTableViewController.gameTypes = self.gameTypes
            newGameTableViewController.game = self.game
            newGameTableViewController.gameStatus = .EDIT
            newGameTableViewController.address = embeddedViewController?.address
        }
    }
    
}
