//
//  InitialUITabBarController.swift
//  Pickup
//
//  Created by Justin Carver on 7/29/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import UIKit

class InitialUITabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if defaultPlayer.firstName == "firstName" {
            self.performSegue(withIdentifier: "toLoginView", sender: self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
