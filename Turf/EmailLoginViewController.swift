//
//  EmailLoginViewController.swift
//  Pickup
//
//  Created by Justin Carver on 8/9/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import UIKit
import FirebaseAuth

class EmailLoginViewController: UIViewController {
    
    var loginButtonHasBeenTappedTimes = 0
    
    //==========================================================================
    //  MARK: - Outlets
    //==========================================================================

    @IBOutlet var emailTextView: UITextField!
    @IBOutlet var passwordTextView: UITextField!
    
    //==========================================================================
    //  MARK: - Actions
    //==========================================================================

    @IBAction func logInButtonTapped(_ sender: Any) {
        loginButtonHasBeenTappedTimes += 1
        if loginButtonHasBeenTappedTimes >= 3 {
            Auth.auth().signIn(withEmail: emailTextView.text ?? "", password: passwordTextView.text ?? "", completion: { (user, error) in
                if error != nil {
                    self.presentAlertController(with: "Something went wrong when we tried to log you in", message: "Please check the information you entered and retry", and: [])
                    print(error?.localizedDescription ?? "\(error!)")
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            return
        }
        
        guard let email = emailTextView.text, email != "", email.last == "m" || email.last == "t" else { self.presentAlertController(with: "Please check that you have entered a valid email and retry", and: []); return }
        guard let password = passwordTextView.text, password != "" else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.presentAlertController(with: "Something went wrong when we tried to log you in", message: "Please check the information you entered and retry", and: [])
                print(error?.localizedDescription ?? "\(error!)")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func presentAlertController(with string: String, message: String = "", and actions: [UIAlertAction]) {
        let alertController = UIAlertController.init(title: string, message: message, preferredStyle: .alert)
        if actions == [] {
            let okAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(okAction)
        } else {
            for action in actions {
                alertController.addAction(action)
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
