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

    

    @IBOutlet weak var lblLocationName: UILabel!
    @IBOutlet weak var lblOpenings: UILabel!
    @IBOutlet weak var imgGameType: UIImageView!
    @IBOutlet weak var btnJoinGame: UIBarButtonItem!
    
    var game: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        btnJoinGame.tintColor = Theme.ACCENT_COLOR
        
        lblLocationName.text = game.locationName
        lblOpenings.text = ("\(game.availableSlots) openings")
        
        if game.userJoined == true {
            btnJoinGame.title = "Leave Game"
        } else {
            btnJoinGame.title = "Join Game"
        }
        
        imgGameType.image = UIImage(named: game.gameType.imageName)
        
    }
    
    
    @IBAction func btnJoinGame(sender: AnyObject) {
        
        //Get the PFObject for game
        //Add the current user as a player in the game
        let title = self.btnJoinGame.title
        
        var message = "Are you sure you want to join this game?"
        var alertTitle = "Join"

        if game.userJoined == true {
            message = "Are you sure you want to leave this game?"
            alertTitle = "Leave"
        }
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
        alertController.addAction(UIAlertAction(title: alertTitle, style: UIAlertActionStyle.Default, handler: { action in
            
            if self.game.userJoined == false {
                //Join user to game
                self.joinPFUserToPFGame()
                self.addGameToUserDefaults()
                self.game.availableSlots += -1
                self.adjustScreenForJoinedUser()
                self.game.userJoined = !self.game.userJoined
            } else {
                //Remove user from game
                self.removePFUserFromPFGame()
                self.removeGameFromUserDefaults()
                self.game.userJoined = !self.game.userJoined
                self.game.availableSlots += 1
                self.adjustScreenForLeavingUser()

            }

        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let embeddedViewController = segue.destinationViewController as? GameDetailsTableViewController
        embeddedViewController?.game = self.game
    }
    
    func adjustScreenForJoinedUser() {
        self.btnJoinGame.title = "Leave Game"
        lblOpenings.text = ("\(game.availableSlots) openings")
        
        if let gameDetailsTableViewController = self.childViewControllers.first as? GameDetailsTableViewController {
            gameDetailsTableViewController.btnAddToCalendar.hidden = false
        }

    }
    
    func adjustScreenForLeavingUser() {
        self.btnJoinGame.title = "Join Game"
        lblOpenings.text = ("\(game.availableSlots) openings")
        
        if let gameDetailsTableViewController = self.childViewControllers.first as? GameDetailsTableViewController {
            gameDetailsTableViewController.btnAddToCalendar.hidden = true
        }
        
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
            print(gameIdArray)
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
            print(gameIdArray)
            NSUserDefaults.standardUserDefaults().setObject(gameIdArray, forKey: "userJoinedGamesById")
        }
        
    }
    
}
