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
    
    var gameTypes:[GameType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadObjectsFromParse()
        
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

        cell?.lblSport.text = gameTypes[indexPath.row].displayName
        cell?.imgSport.image = UIImage(named: gameTypes[indexPath.row].imageName)
        

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }


    private func loadObjectsFromParse() {
        let query = PFQuery(className: "GameType")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let gameTypeObjects = objects {
                
                self.gameTypes.removeAll(keepCapacity: true)
                
                for gameTypeObject in gameTypeObjects {
                    
//                    query.whereKey(<#T##key: String##String#>, containedIn: <#T##[AnyObject]#>)
//                    query.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
//                        <#code#>
//                    })
                    
                    let gameType = GameTypeFactory.convertParseObject(gameTypeObject)
                    self.gameTypes.append(gameType)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
