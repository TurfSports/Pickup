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
    @IBOutlet weak var toolbar: UIToolbar!
    var game: Game!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnJoinGame.tintColor = Theme.PRIMARY_DARK_COLOR
        
        
        lblLocationName.text = game.locationName
        lblOpenings.text = ("\(game.availableSlots) openings")
        
        
        imgGameType.image = UIImage(named: game.gameType.imageName)
        
    }
    
    
    @IBAction func btnJoinGame(sender: AnyObject) {
        
        //Get the PFObject for game
        //Add the current user as a player in the game
        let alertController = UIAlertController(title: "Join Game", message:
            "Are you sure you want to join this game?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
        alertController.addAction(UIAlertAction(title: "Join", style: UIAlertActionStyle.Default, handler: { action in
            switch action.style {
            case .Default:
                print("default")
                
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    
        
        joinPFUserToPFGame()
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let embeddedViewController = segue.destinationViewController as? GameDetailsTableViewController
        embeddedViewController?.game = self.game
    }
    
    //MARK: - Load game from parse
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
                object?.saveInBackground()
            }
        }
    
    }
    
}
