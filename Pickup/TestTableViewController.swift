//
//  TestTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 11/1/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import Parse

class TestTableViewController: UITableViewController {

    var selectedGameType:GameType!
    var gameTypes:[GameType]!
    var games: [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.games.count
    }
    
    
    
    
    func loadGamesFromParse() {
        let gameQuery = PFQuery(className: "Game")
        
        //        gameQuery.whereKey("gameType", equalTo: PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id))
        gameQuery.whereKey("gameType", equalTo: PFObject(outDataWithClassName: "GameType", objectId: selectedGameType.id))
        
        var userGeoPoint = PFGeoPoint(latitude: Settings.sharedSettings.defaultLatitude, longitude: Settings.sharedSettings.defaultLongitude)
    
        
        //        gameQuery.whereKey("gameType", equalTo: PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id))
        gameQuery.whereKey("gameType", equalTo: PFObject(outDataWithClassName: "GameType", objectId: selectedGameType.id))
        
        if Settings.sharedSettings.distanceUnit == "miles" {
            let gameDistance = Double(Settings.sharedSettings.gameDistance)
            gameQuery.whereKey("location", nearGeoPoint:userGeoPoint, withinMiles:gameDistance)
        } else {
            let gameDistance = Double(Settings.sharedSettings.gameDistance)
            gameQuery.whereKey("location", nearGeoPoint:userGeoPoint, withinKilometers:gameDistance)
        }
        
        gameQuery.whereKey("date", greaterThanOrEqualTo: Date().addingTimeInterval(-1.5 * 60 * 60))
        gameQuery.whereKey("date", lessThanOrEqualTo: Date().addingTimeInterval(2 * 7 * 24 * 60 * 60))
        gameQuery.whereKey("isCancelled", equalTo: false)
        gameQuery.whereKey("slotsAvailable", greaterThanOrEqualTo: 1)
        
        if Settings.sharedSettings.showCreatedGames == false {
            gameQuery.whereKey("owner", notEqualTo: PFUser.current()!)
        }
        
        gameQuery.findObjectsInBackground { (objects, error) -> Void in
            if let gameObjects = objects {
                self.games.removeAll(keepingCapacity: true)
                for gameObject in gameObjects {
                    let game = GameConverter.convertParseObject(gameObject, selectedGameType: self.selectedGameType)
                    
                    if (gameObject["owner"] as AnyObject).objectId == PFUser.current()?.objectId {
                        game.userIsOwner = true
                    }
                    
                    if let joinedGames = UserDefaults.standard.object(forKey: "userJoinedGamesById") as? NSArray {
                        if joinedGames.contains(game.id) {
                            game.userJoined = true
                        }
                    }
                    self.games.append(game)
                }
            } else {
                print(error)
            }
            
            if self.games.count == 0 {
                print("NO GAMES")
            } else {
                self.tableView.reloadData()
            }
            
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath)

        cell.textLabel?.text = self.games[indexPath.row].gameType.displayName
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
