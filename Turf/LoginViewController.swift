//
//  LoginViewController.swift
//  Pickup
//
//  Created by Justin Carver on 7/29/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    var failedLoginAlertController = UIAlertController.init()
    
    @IBOutlet var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        failedLoginAlertController = UIAlertController.init(title: "Something went wrong when we tried to log you in. Please try again", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
        failedLoginAlertController.addAction(okAction)
        self.navigationController!.navigationBar.tintColor = Theme.PRIMARY_LIGHT_COLOR
    }
    
    // MARK: - Google Login
    
    @IBAction func googleLoginButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toQuestionsFromFacebookOrGoogle", sender: nil)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        if error != nil {
            print(error.localizedDescription)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.performSegue(withIdentifier: "toQuestionsFromFacebookOrGoogle", sender: self)
    }
    
    // MARK: - Facebook Login
    
    @IBAction func facebookLoginButtonTapped(_ sender: Any) {
        let manager = FBSDKLoginManager.init()
        manager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (loginResult, error) in
            guard loginResult?.isCancelled != true && error == nil else {
                
                self.present(self.failedLoginAlertController, animated: true, completion: nil)
                return
            }
            
            let notification = Notification(name: Notification.Name(rawValue: "facebookLoggedIn"))
            NotificationCenter.default.post(notification)

            self.performSegue(withIdentifier: "toQuestionsFromFacebookOrGoogle", sender: self)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toQuestionsFromFacebookOrGoogle" {
            guard let destinationVC = segue.destination as? QuestionsTableViewController else { return }
            destinationVC.age = Int(currentPlayer.age)
            destinationVC.image = currentPlayer.userImage
            destinationVC.firstName = currentPlayer.firstName
            destinationVC.lastName = currentPlayer.lastInitials
            destinationVC.gender = currentPlayer.gender
            destinationVC.needsEmailAndPassword = false
        }
    }
}
