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
    
    let SEGUE_SHOW_GAMES = "showGamesTableViewController"
    let SEGUE_SHOW_NEW_GAME = "showNewGameTableViewController"
    
    var gameTypes:[GameType] = []
    var gameCountLoaded:Bool = false {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var addNewGameButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        addNewGameButton.tintColor = Theme.ACCENT_COLOR
        self.navigationController!.navigationBar.tintColor = Theme.PRIMARY_LIGHT_COLOR
        loadGameTypesFromParse()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)

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
            let gamesViewController = segue.destinationViewController as! GameListTableViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                gamesViewController.selectedGameType = gameTypes[indexPath.row]
                gamesViewController.gameTypes = self.gameTypes
            }
            gamesViewController.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == SEGUE_SHOW_NEW_GAME {
            let navigationController = segue.destinationViewController as! UINavigationController
            let newGameTableViewController = navigationController.viewControllers.first as! NewGameTableViewController
            print(self.gameTypes)
            newGameTableViewController.gameTypes = self.gameTypes
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SEGUE_SHOW_GAMES, sender: self)
    }
    

}
