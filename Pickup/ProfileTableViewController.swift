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
    
    @IBOutlet var nameDetailOutlet: UILabel!
    @IBOutlet var ageDetailOutlet: UILabel!
    @IBOutlet var genderDetailOutlet: UILabel!
    @IBOutlet var numberOfGamesCreatedDetailOutlet: UILabel!
    @IBOutlet var numberOfJoinedCreatedDetailOutlet: UILabel!
    
    override func viewDidLoad() {
        loadPofileDetails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPofileDetails()
    }
    
    // MARK: - Table view data source
    
    func logOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            facebookLoginManager.logOut()
            GIDSignIn.sharedInstance().signOut()
            hasLogedInBefore = false
            self.performSegue(withIdentifier: "toLoginView", sender: self)
        } catch let signOutError {
            print ("Error signing out: \(signOutError)")
        }
    }
    
    func loadPofileDetails() {
        nameDetailOutlet.text = currentPlayer.firstName + " " + currentPlayer.lastInitials
        ageDetailOutlet.text = currentPlayer.age
        genderDetailOutlet.text = currentPlayer.gender.capitalized
        numberOfGamesCreatedDetailOutlet.text = "\(currentPlayer.createdGames.count)"
        numberOfJoinedCreatedDetailOutlet.text = "\(currentPlayer.joinedGames.count)"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            logOut()
        }
    }
}
