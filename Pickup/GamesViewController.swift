//
//  GamesViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/23/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit

class GamesViewController: UIViewController, UITableViewDelegate {

    //MARK: - Local variables
    
    var gameType:GameType!
    var games:[Game]!
    var selectedGame:Game!
    
    //MARK: - Local constants
    
    let SEGUE_SHOW_GAME_DETAIL = "ShowGameDetailViewController"
    
    //MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableView Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "GameCell")
//        let cell = tableView.dequeueReusableCellWithIdentifier("GameCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = "\(games[indexPath.row].owner.username)"
        cell.detailTextLabel?.text = "\(games[indexPath.row].location)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedGame = games[indexPath.row]
        performSegueWithIdentifier(SEGUE_SHOW_GAME_DETAIL, sender: self)
    }
    
    
    //MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let gameDetailViewController = segue.destinationViewController as! GameDetailViewController
        gameDetailViewController.game = selectedGame
        gameDetailViewController.navigationItem.leftItemsSupplementBackButton = true
        print("prepareForSegue")
    }
    
    
    //MARK: - Custom functions
    
    func loadGameArray(dict: Dictionary<String, Game>) -> Array<Game> {
        var gameArray: [Game] = []
        for (_, value) in dict {
            gameArray.append(value)
        }
        return gameArray
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
