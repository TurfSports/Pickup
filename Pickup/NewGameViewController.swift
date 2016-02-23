//
//  NewGameViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/22/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit

class NewGameViewController: UIViewController {

    let SEGUE_CONTAINER_TABLE_VIEW = "showEmbeddedContainerView"
    
    var selectedGameType:GameType?
    var gameTypes:[GameType]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let embeddedViewController = segue.destinationViewController as? NewGameTableViewController
        embeddedViewController?.gameTypes = self.gameTypes
        embeddedViewController?.selectedGameType = self.selectedGameType
    }
    
    
    

}
