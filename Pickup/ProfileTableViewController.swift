//
//  ProfileTableViewController.swift
//  Pickup
//
//  Created by Justin Carver on 8/1/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ProfileTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source

    @IBAction func logOutButtonTapped(_ sender: Any) {
        facebookLoginManager.logOut()
    }
}
