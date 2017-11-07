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

let kLoginProvider = "loginProvider"
let kHasLogedInBefore = "firstTimeLogin"
let kUID = "ID"
var loginProvider = ""
var hasLogedInBefore: Bool = false
let facebookLoggedInNotificationName = Notification.Name(rawValue: "facebookLoggedIn")
let facebookInformationLoadedNotificationName = Notification.Name(rawValue: "facebookInfoLoaded")
let gamesLoadedNotificationName = NSNotification.Name.init("gamesLoaded")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    var uID: String = "" {
        didSet {
            currentPlayer.id = uID
            saveUID(uid: uID)
        }
    }
    
    @objc func addGamesToGameArrays() {
        DispatchQueue.main.async {
            let gamesCreated: [Game] = loadedGames.filter({ $0.ownerId == currentPlayer.id })
            currentPlayer.createdGames = gamesCreated
            self.putLoadedPlayerToFirebase()
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(self, selector: #selector(authFacebook), name: facebookLoggedInNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(putLoadedPlayerToFirebase), name: facebookInformationLoadedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addGamesToGameArrays), name: gamesLoadedNotificationName, object: nil)
        
        // Sign in
        
        loadLoginProvider()
        loadFirstTimeLogin()
        loadUID()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        
        if hasLogedInBefore {
            if let playerID = UserDefaults.standard.string(forKey: kUID) {
                currentPlayer.id = playerID
            }
        }
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
        if loginProvider == "Facebook" {
            self.authFacebook()
        } else if loginProvider == "Google" {
            if let currentUser = GIDSignIn.sharedInstance().currentUser {
                self.AuthGoogle(with: currentUser)
            }
        } else {
            GIDSignIn.sharedInstance().signInSilently()
        }
        
        //        Database.database().isPersistenceEnabled = true
        
        // Load Games and location
        
        Theme.applyTheme()
        
        OverallLocation.manager.requestWhenInUseAuthorization()
        
        GameController.shared.loadGames { (games) in
            DispatchQueue.main.async {
                loadedGames = games
                NotificationCenter.default.post(name: gamesLoadedNotificationName, object: nil)
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
    
    func loadFirstTimeLogin() {
        let firstTimeLoginBool = UserDefaults.standard.bool(forKey: kHasLogedInBefore)
        hasLogedInBefore = firstTimeLoginBool
    }
    
    func saveFirstTimeLogin(firstTimeLogin: Bool) {
        UserDefaults.standard.set(firstTimeLogin, forKey: kHasLogedInBefore)
    }
    
    func loadUID() {
        guard let uid = UserDefaults.standard.string(forKey: kUID) else { return }
        uID = uid
    }
    
    func saveUID(uid: String) {
        UserDefaults.standard.set(uid, forKey: kUID)
    }
    
    @objc func putLoadedPlayerToFirebase() {
        PlayerContoller.shared.put(player: currentPlayer, success: { (success) in
            if success {
                hasLogedInBefore = !hasLogedInBefore
                self.saveFirstTimeLogin(firstTimeLogin: hasLogedInBefore)
                print("Saved player to firebase")
            }
        })
    }
    
    // MARK: Email
    
    func signIn(with email: String, and password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard error == nil else {
                print("Unalbe to login with email")
                return
            }
            
            loginProvider = email
            
            if let id = user?.uid {
                if self.uID == "" {
                    self.uID = id
                }
            }
            
            PlayerContoller.shared.getPlayer(completion: { (player) in
                currentPlayer = player!
            })
        }
    }
    
    // MARK: Facebook Authentication
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    @objc func authFacebook() {
        let facebookAccessToken = FBSDKAccessToken.current()
        
        facebookHasLoggedInBefore()
        
        guard facebookAccessToken != nil else { print("User needs to login"); return }
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        saveLoginProvider(provider: "Facebook")
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Could not Authenticate with firebase. ErrorCode: \(error.localizedDescription) Error Details \(error)")
                return
            } else if let currentUser = user {
                if self.uID == "" {
                    self.uID = currentUser.uid
                }
                
                print("Logged into firebase with current user")
                return
            }
        }
    }
    
    func facebookHasLoggedInBefore() {
        if !hasLogedInBefore {
            requestFacebookInformation()
        } else {
            PlayerContoller.shared.getPlayer(completion: { (player) in
                if let unwrapedPlayer = player {
                    currentPlayer = unwrapedPlayer
                }
            })
        }
    }
    
    func requestFacebookInformation() {
        let request = FBSDKGraphRequest.init(graphPath: "/me", parameters: ["fields" : "first_name,last_name,gender,age_range"], httpMethod: "GET")
        
        let connection = request?.start(completionHandler: { (connection, idResult, error) in
            guard error == nil, let result = idResult as? [String: Any] else { print("\(error?.localizedDescription ?? "Erorr with result Dictionary")"); return }
            guard let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String, let gender = result["gender"] as? String, let ageRange = result["age_range"] as? [String: Int], let maxAge = ageRange["max"] else { return }
            
            currentPlayer.age = "\(maxAge)"
            currentPlayer.gender = gender
            currentPlayer.firstName = firstName
            let lastNameCharCount = lastName.count
            if lastNameCharCount >= 3 {
                let lastInitialsCharView = lastName.dropLast(lastNameCharCount - 2)
                let lastInitials = String.init(lastInitialsCharView)
                currentPlayer.lastInitials = "\(lastInitials)" + "."
            } else {
                currentPlayer.lastInitials = lastName + "."
            }
            self.putLoadedPlayerToFirebase()
            NotificationCenter.default.post(name: facebookInformationLoadedNotificationName, object: nil)
        })
        
        connection?.start()
    }
    
    // MARK: Google
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            
            let fbURLCharacters = url.absoluteString
            
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
                } else if let id = user?.uid {
                    if self.uID == "" {
                        self.uID = id
                    }
                    if !hasLogedInBefore {
                        self.requestGoogleInformation()
                    } else {
                        PlayerContoller.shared.getPlayer(completion: { (player) in
                            DispatchQueue.main.async {
                                guard let player = player else { return  }
                                currentPlayer = player
                            }
                        })
                    }
                }
            }
        }
    }
    
    func requestGoogleInformation() {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let fullName = currentUser.displayName
        let fullNameArr = fullName?.split(separator: " ").map(String.init)
        
        var firstName: String? {
            guard let fullNameArr = fullNameArr else { return nil }
            return fullNameArr[0].count > 1 ? fullNameArr[0] : nil
        }
        
        var lastInitials: String? {
            guard let fullNameArr = fullNameArr else { return nil }
            guard let lastName = fullNameArr[1].count > 1 ? fullNameArr[1] : nil else { return nil }
            var lastInitials: String
            let charCount = lastName.count
            if charCount >= 3 {
                lastInitials = String.init(lastName.dropLast(charCount - 2)) + "."
            } else {
                lastInitials = lastName + "."
            }
            return lastInitials
        }
        
        var photoUrlString: String {
            guard currentUser.photoURL?.absoluteString != nil else { return "" }
            return (currentUser.photoURL?.absoluteString)!
        }
        
        var email: String {
            guard currentUser.email != nil else { return "" }
            return currentUser.email!
        }
        
        if self.uID == "" {
            uID = currentUser.uid
        }
        
        let player = Player.init(id: uID, firstName: firstName ?? "FirstName", lastName: lastInitials ?? "LastName", userImage: nil, userCreationDate: Date.init(), userImageEndpoint: photoUrlString, createdGames: [], joinedGames: [], age: "", gender: "undisclosed", sportsmanship: "", skills: [:])
        currentPlayer = player
        putLoadedPlayerToFirebase()
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
        
        saveUID(uid: uID)
        saveLoginProvider(provider: loginProvider)
        saveFirstTimeLogin(firstTimeLogin: hasLogedInBefore)
        
        let serializedSettings = Settings.serializeSettings(Settings.shared)
        Settings.saveSettings(serializedSettings)
    }
}

