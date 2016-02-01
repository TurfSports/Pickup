//
//  GamesTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/1/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class GamesTableViewController: PFQueryTableViewController {

    let SEGUE_SHOW_GAME_DETAILS = "showGameDetailsViewController"
    var gameType:PFObject!
    
    // Initialise the PFQueryTable tableview
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // Configure the PFQueryTableView
        self.parseClassName = "Game"
        self.textKey = "owner"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Game")
        query.whereKey("gameType", equalTo: gameType)
        query.includeKey("owner")
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        let cell = PFTableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        
        if let owner = object?["owner"]["username"] as? String {
            cell.textLabel?.text = owner
        }
        
        if let totalSlots = object?["slotsAvailable"] as? Int {
            cell.detailTextLabel?.text = "\(totalSlots) slots"
        }
        
        Theme.applyThemeToCell(cell)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SEGUE_SHOW_GAME_DETAILS, sender: self)
    }
    
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SHOW_GAME_DETAILS {
            let gameDetailsViewController = segue.destinationViewController as! GameDetailsViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let row = Int(indexPath.row)
                gameDetailsViewController.game = (objects![row])
            }
            gameDetailsViewController.navigationItem.leftItemsSupplementBackButton = true
        }
        
    }
    
    
    


}
