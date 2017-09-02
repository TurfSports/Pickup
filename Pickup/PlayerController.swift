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
    
    let endUrl = URL.init(string: "https://pickup-a837a.firebaseio.com")
    
    func put(player: Player, success: @escaping (Bool) -> Void) {
        ref.child("Players").child(player.id).setValue(player.jsonDictionary)
        success(true)
        return
    }
    
    func put(createdGames: [Game], or joinedGames: [Game], for player: Player) {
        if createdGames.count != 0 && joinedGames.count == 0 {
            ref.child("Players").child(player.id).child("createdGames").setValue(createdGames)
            return
        } else if joinedGames.count != 0 && createdGames.count == 0 {
            ref.child("Players").child(player.id).child("joinedGames").setValue(joinedGames)
            return
        } else if joinedGames.count != 0 && createdGames.count != 0 {
            ref.child("Players").child(player.id).child("createdGames").setValue(createdGames)
            ref.child("Players").child(player.id).child("joinedGames").setValue(joinedGames)
            return
        } else {
            return
        }
    }
    
    func put(player: Player, to url: URL?, success: @escaping (Bool) -> Void) {
        
        let newUrl: URL
        
        if url == nil {
            newUrl = endUrl!
        } else {
            newUrl = url!
        }
        
        let urlWithUUID = newUrl.appendingPathComponent("Players").appendingPathComponent(player.id).appendingPathExtension("json")
        
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
        ref.child("Players").child("\(currentPlayer.id)").observeSingleEvent(of: .value, with: { (snapShot) in
           
            guard let jsonObject = snapShot.value as? [String: Any] else { completion(nil); print("Fuck") ; return }
            
            guard let user = Player(dictionary: jsonObject) else { completion(nil); print("Could not create user"); return }
            
            currentPlayer = user
        })
    }
}
