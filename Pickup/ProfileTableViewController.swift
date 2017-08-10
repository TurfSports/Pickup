//
//  ProfileTableViewController.swift
//  Pickup
//
//  Created by Justin Carver on 8/1/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

class ProfileTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source

    @IBAction func logOutButtonTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            facebookLoginManager.logOut()
            GIDSignIn.sharedInstance().signOut()
        } catch let signOutError {
            print ("Error signing out: \(signOutError)")
        }
    }
}
