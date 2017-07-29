//
//  LoginViewController.swift
//  Pickup
//
//  Created by Justin Carver on 7/29/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func googleLoginButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func facebookLoginButtonTapped(_ sender: Any) {
        
        let manager = FBSDKLoginManager.init()
        manager.logIn(withReadPermissions: [], from: self) { (loginResult, error) in
            
            guard error == nil && loginResult?.isCancelled != true else {
                let alertController = UIAlertController.init(title: "An error occured while logging you in, please try again", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
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
