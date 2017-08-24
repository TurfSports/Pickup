//
//  AppDelegate.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/18/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import GoogleSignIn
import FirebaseAuth
import FBSDKLoginKit

var loginProvider = ""
let kLoginProvider = "loginProvider"
let gamesLoadedNotificationName = NSNotification.Name.init("gamesLoaded")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(self, selector: #selector(AuthFacebook), name: Notification.Name(rawValue: "facebookLoggedIn"), object: nil)
        
        // Sign in
        
        loadLoginProvider()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
        if loginProvider == "Facebook" {
            self.AuthFacebook()
        } else if loginProvider == "Google" {
            self.AuthGoogle(with: GIDSignIn.sharedInstance().currentUser)
        } else {
            GIDSignIn.sharedInstance().signInSilently()
        }
        
//        Database.database().isPersistenceEnabled = true
        
        // Load Games and location
        
        Theme.applyTheme()
        
        OverallLocation.manager.requestWhenInUseAuthorization()
        
        GameController.shared.loadGames { (Games) in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: gamesLoadedNotificationName, object: nil)
                loadedGames = Games
            }
        }
        
        // Set up current user
        
        if NotificationsManager.notificationsInitiated() {
            NotificationsManager.registerNotifications()
        }
        
        if let options = launchOptions {
            if let notification = options[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "com.pickup.loadGameFromNotificationWithSegue"), object: nil, userInfo: notification.userInfo)
            }
        }
        
        //Set up user defaults
        //Intialize first pull of game types. Only pull these once a day
        if let _ = UserDefaults.standard.object(forKey: "gameTypePullTimeStamp") as? Date {
            //Pass
        } else {
            let lastPull = Date().addingTimeInterval(-25 * 60 * 60) //Default to a day ago
            UserDefaults.standard.set(lastPull, forKey: "gameTypePullTimeStamp")
        }
        
        //Initialize settings
        if let settingsFromUserDefaults = UserDefaults.standard.object(forKey: "Settings") as? [String: Any] {
            
            let storedSettings = Settings.deserializeSettings(settingsFromUserDefaults)
            Settings.shared.gameDistance = storedSettings.gameDistance
            Settings.shared.distanceUnit = storedSettings.distanceUnit
            Settings.shared.gameReminder = storedSettings.gameReminder
            Settings.shared.defaultLocation = storedSettings.defaultLocation
            Settings.shared.defaultLatitude = storedSettings.defaultLatitude
            Settings.shared.defaultLongitude = storedSettings.defaultLongitude
            Settings.shared.showCreatedGames = storedSettings.showCreatedGames
            
        } else {
            let serializedSettings = Settings.serializeSettings(Settings.shared)
            Settings.saveSettings(serializedSettings)
        }
        return true
    }
    
    //==========================================================================
    //  MARK: - Remote Notifications
    //==========================================================================
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Setup User
        
        //        let installation = PFInstallation.current()
        //        installation?["user"] = PFUser.current()
        //        installation?.setDeviceTokenFrom(deviceToken)
        //        installation?.saveInBackground()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
    }
    
    //==========================================================================
    //  MARK: - Load/Login
    //==========================================================================
    
    // MARK: Login Provider
    
    func loadLoginProvider() {
        guard let provider = UserDefaults.standard.string(forKey: kLoginProvider) else { loginProvider = ""; return }
        loginProvider = provider
    }
    
    func saveLoginProvider(provider: String) {
        UserDefaults.standard.set(provider, forKey: kLoginProvider)
    }
    
    // MARK: Email
    
    func signIn(with email: String, and password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard error == nil else {
                print("Unalbe to login with email")
                return
            }

            if let id = user?.uid {
                currentPlayer.id = id
            }
        }
    }
    
    // MARK: Facebook Authentication
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func AuthFacebook() {
        let facebookAccessToken = FBSDKAccessToken.current()
        
        if facebookAccessToken != nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            saveLoginProvider(provider: "Facebook")
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print("Could not Authenticate with firebase. ErrorCode: \(error.localizedDescription) Error Details \(error)")
                    return
                } else {
                    print("Logged into firebase with current user")
                }
            }
        } else {
            print("Need to login")
        }
        
        
    }
    
    // MARK: Google
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {

            let fbURLCharacters = url.absoluteString.characters
            
            if fbURLCharacters.first == "f" && fbURLCharacters.last == "D" {
                return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: options)
            }
            
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        guard error == nil else {
            print(error?.localizedDescription ?? "There was a problem signing in with google.")
            return
        }
        AuthGoogle(with: user)
    }
    
    func AuthGoogle(with user: GIDGoogleUser) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        saveLoginProvider(provider: "Google")
        Auth.auth().signIn(with: credential) { (user, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Could not Authenticate with firebase. ErrorCode: \(error.localizedDescription) Error Details \(error)")
                    return
                }
                guard let currentUser = Auth.auth().currentUser else { return }
                let fullName = currentUser.displayName
                let fullNameArr = fullName?.characters.split(separator: " ").map(String.init)
                
                var firstName: String? {
                    guard let fullNameArr = fullNameArr else { return nil }
                    return fullNameArr[0].characters.count > 1 ? fullNameArr[0] : nil
                }
                
                var lastName: String? {
                    guard let fullNameArr = fullNameArr else { return nil }
                    return fullNameArr[1].characters.count > 1 ? fullNameArr[1] : nil
                }
                
                var photoUrlString: String {
                    guard currentUser.photoURL?.absoluteString != nil else { return "" }
                    return (currentUser.photoURL?.absoluteString)!
                }
                
                var email: String {
                    guard currentUser.email != nil else { return "" }
                    return currentUser.email!
                }
                
                let player = Player.init(id: currentUser.uid, firstName: firstName ?? "FirstName", lastName: lastName ?? "LastName", userImage: nil, userCreationDate: Date.init(), userImageEndpoint: photoUrlString, createdGames: [], joinedGames: [], age: "", gender: "undisclosed", sportsmanship: "", skills: [:])
                currentPlayer = player
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    
    //==========================================================================
    //  MARK: - Local Notifications
    //==========================================================================
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        if (application.applicationState == .background || application.applicationState == .inactive) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "com.pickup.loadGameFromNotificationWithSegue"), object: nil, userInfo: notification.userInfo)
        } else {
            if notification.userInfo!["showAlert"] as? String == "true" {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "com.pickup.loadGameFromNotificationWithAlert"), object: nil, userInfo: notification.userInfo)
            }
        }
    }
    
    //==========================================================================
    //  MARK: - App Will Terminate
    //==========================================================================
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        // TODO - Fix settings so they will save properly
        
        let serializedSettings = Settings.serializeSettings(Settings.shared)
        Settings.saveSettings(serializedSettings)
    }
}

