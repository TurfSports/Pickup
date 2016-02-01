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

class GameDetailsViewController: UIViewController {

    
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lblSlotsAvailable: UILabel!
    var game:PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblOwner.text = "\(game?["owner"])"
        lblSlotsAvailable.text = "\(game?["slotsAvailable"])"
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
