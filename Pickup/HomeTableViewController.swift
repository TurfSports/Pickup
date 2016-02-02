//
//  HomeTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/1/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class HomeTableViewController: PFQueryTableViewController {
    
    let SEGUE_SHOW_GAMES = "showGamesTableViewController"
    
    //MARK: - Initialization
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // Configure the PFQueryTableView
        self.parseClassName = "GameType"
        self.textKey = "displayName"
        self.pullToRefreshEnabled = false
        self.paginationEnabled = false
    }
    
    //MARK: - Query
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "GameType")
        query.orderByAscending("sortOrder")
        return query
    }
    
    
    //MARK: - Table View Delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Theme.GAME_TYPE_CELL_HEIGHT
    }
    
    //override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        let cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        if let imageName = object?["imageName"] as? String {
            let image = UIImage(named: imageName)
            cell.imageView?.image = image
        }
        
        if let displayName = object?["displayName"] as? String {
            cell.textLabel?.text = displayName
        }
        
        Theme.applyThemeToCell(cell)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SEGUE_SHOW_GAMES, sender: self)
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SHOW_GAMES {
            let gamesTableViewController = segue.destinationViewController as! GamesTableViewController
         
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let row = Int(indexPath.row)
                gamesTableViewController.gameType = (objects![row])
            }
            gamesTableViewController.navigationItem.leftItemsSupplementBackButton = true
        }

    }
    
}


