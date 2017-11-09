//
//  PlayerController.swift
//  Pickup
//
//  Created by Justin Carver on 7/11/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class PlayerContoller {
    
    static let shared = PlayerContoller()
    var ref = Database.database().reference()
    var playersRef = Database.database().reference().child("Players")
    var currentLoginProviderRef: DatabaseReference? {
        guard currentPlayer.id != "" else { return nil }
       return playersRef.child(currentPlayer.id).child(loginProvider)
    }
    
    let refUrl = URL.init(string: "https://pickup-a837a.firebaseio.com")
    
    func put(player: Player, success: @escaping (Bool) -> Void) {
        Auth.auth()
        guard let currentLoginProviderRef = currentLoginProviderRef else { success(false); return }
        currentLoginProviderRef.setValue(player.jsonDictionary)
        success(true)
        return
    }
    
    func put(createdGames: [String], or joinedGames: [String]) {
        guard let currentLoginProviderRef = currentLoginProviderRef else { return }
        if createdGames.count != 0 && joinedGames.count == 0 {
            currentLoginProviderRef.child("createdGames").setValue(createdGames)
            return
        } else if joinedGames.count != 0 && createdGames.count == 0 {
            currentLoginProviderRef.child("joinedGames").setValue(joinedGames)
            return
        } else if joinedGames.count != 0 && createdGames.count != 0 {
            currentLoginProviderRef.child("createdGames").setValue(createdGames)
            currentLoginProviderRef.child("joinedGames").setValue(joinedGames)
            return
        } else {
            return
        }
    }
    
    func add(game: Game, to folder: String) {
        guard let currentLoginProviderRef = currentLoginProviderRef else { return }
        currentLoginProviderRef.child(folder).child(game.id).setValue(game.id)
    }
    
    func put(player: Player, to url: URL?, success: @escaping (Bool) -> Void) {
        
        let newUrl: URL
        
        if url == nil {
            newUrl = refUrl!
        } else {
            newUrl = url!
        }
        
        let urlWithUUID = newUrl.appendingPathComponent("Players").appendingPathComponent(player.id).appendingPathComponent(loginProvider).appendingPathExtension("json")
        
        NetworkController.performRequest(for: urlWithUUID, httpMethod: .put, body: player.jsonData) { (data, error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                    success(false)
                    return
                } else {
                    success(true)
                    print("Put Player Info")
                    return
                }
            }
        }
    }
    
    func getPlayer(completion: @escaping (_ player: Player?) -> Void) {
        guard let currentLoginProviderRef = currentLoginProviderRef else { completion(nil); return }
        currentLoginProviderRef.observeSingleEvent(of: .value, with: { (snapShot) in
           
            guard let jsonObject = snapShot.value as? [String: Any] else { completion(nil); print("Json object not initialized on get player funtion") ; return }
            
            guard let user = Player(dictionary: jsonObject, and: "") else { completion(nil); print("Could not create user"); return }
            
            currentPlayer = user
        })
    }
    
    func getPlayersForPlayerList(userIDs: [String], completion: @escaping (_ players: [Player]) -> Void) {
        for id in userIDs {
            
        }
    }
}
