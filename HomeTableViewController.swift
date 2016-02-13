//
//  HomeTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/8/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import Parse

class HomeTableViewController: UITableViewController {
    
    var data:ParseDataController!
    
    let SEGUE_SHOW_GAMES = "showGamesTableViewController"
    var gameTypes:[GameType] = []
    var gameCountLoaded:Bool = false {
        didSet {
            self.tableView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameTypesFromParse()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell?.lblAvailableGames.text = "\(gameType.gameCount) games"
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Theme.GAME_TYPE_CELL_HEIGHT
    }


    private func loadGameTypesFromParse() {
        let gameTypeQuery = PFQuery(className: "GameType")
        gameTypeQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let gameTypeObjects = objects {
                
                self.gameTypes.removeAll(keepCapacity: true)
                
                for gameTypeObject in gameTypeObjects {
                    var gameCount:Int = 0
                    
                    let gameQuery = PFQuery(className: "Game")
                    gameQuery.whereKey("gameType", equalTo: gameTypeObject)
                    
                    let gameType = GameTypeConverter.convertParseObject(gameTypeObject)
                    
                    gameQuery.countObjectsInBackgroundWithBlock({ (count: Int32, error: NSError?) -> Void in
                        gameCount = Int(count)
                        gameType.increaseGameCount(gameCount)
                        self.gameCountLoaded = true
                    })
                    
                    self.gameTypes.append(gameType)
                }
            }
            
            self.tableView.reloadData()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SHOW_GAMES {
            let gamesViewController = segue.destinationViewController as! GameTableViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                gamesViewController.selectedGameType = gameTypes[indexPath.row]
            }
            gamesViewController.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SEGUE_SHOW_GAMES, sender: self)
    }
    

}
