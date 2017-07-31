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
    
    var loginResult: FBSDKLoginManagerLoginResult?

    @IBOutlet var facebookLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fbLoginButton = FBSDKLoginButton.init()
        
        self.view.addSubview(fbLoginButton)
        
        fbLoginButton.center = self.view.center
                
        fbLoginButton.readPermissions = ["public_profile", "email"]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        let middleXConstraint = NSLayoutConstraint.init(item: fbLoginButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
//        let bottomConstraint = NSLayoutConstraint.init(item: fbLoginButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottomMargin, multiplier: 1, constant: 8)
//        
//        fbLoginButton.addConstraint(middleXConstraint)
//        fbLoginButton.addConstraint(bottomConstraint)
    }
    
    @IBAction func googleLoginButtonTapped(_ sender: Any) {
        
        
    }

    @IBAction func facebookLoginButtonTapped(_ sender: Any) {
        let manager = FBSDKLoginManager.init()
        manager.logIn(withReadPermissions: ["public_profile"], from: self) { (loginResult, error) in
            guard loginResult?.isCancelled != true && error == nil else {
                let alertController = UIAlertController.init(title: "Something went wrong when we tried to log you in. Please try again", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            self.loginResult = loginResult
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
