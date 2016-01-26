//
//  HomeViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/22/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate {
    
    //MARK: - Local variables
    var dummyData:DummyDataController!
    var gameTypes:[GameType]!
    
    //MARK: - Variables for next view controller
    var selectedGameType:GameType!
    
    //MARK: - Local constants
    let SEGUE_SHOW_GAMES = "ShowGamesViewController"
    
    //MARK: - ViewController functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dummyData = DummyDataController.init()
    }
    
    //MARK: - TableView Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyData.gameType.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "GameTypeCell")
        
        gameTypes = loadGameTypeArray(dummyData.gameType)
        
        cell.textLabel?.text = gameTypes[indexPath.row].displayName
        cell.imageView?.image = UIImage(named: gameTypes[indexPath.row].imageName)
        cell.imageView?.layer.frame.size = CGSizeMake(10.0, 10.0)
        cell.imageView?.layer.cornerRadius = 50
        cell.imageView?.layer.masksToBounds = true
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedGameType = gameTypes[indexPath.row]
        performSegueWithIdentifier(SEGUE_SHOW_GAMES, sender: self)
    }
    
    //MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SHOW_GAMES {
            let gamesViewController = segue.destinationViewController as! GamesViewController
            gamesViewController.games  = loadGameArray(dummyData.games, gameType: selectedGameType)
            gamesViewController.gameType = selectedGameType
        }
    }
    
    //MARK: - Custom functions
    
    func loadGameTypeArray(dict: Dictionary<String, GameType>) -> Array<GameType> {
        
        var gameTypeArray: [GameType] = []
        
        for (_, value) in dict {
            gameTypeArray.append(value)
        }
        
        return gameTypeArray
        
    }
    
    func loadGameArray(dict: Dictionary<String, Game>, gameType: GameType) -> Array<Game> {
        var gameArray: [Game] = []
        for (_, value) in dict {
            if value.gameType.id == gameType.id {
                gameArray.append(value)
            }
        }
        return gameArray
    }
}


