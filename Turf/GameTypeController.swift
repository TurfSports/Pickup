//
//  GameTypeController.swift
//  Pickup
//
//  Created by Justin Carver on 5/31/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import Foundation
import Firebase

let gameTypeURL = URL(string: "https://pickup-a837a.firebaseio.com/Game%20Types.json")

class GameTypeController {
    
    static let shared = GameTypeController()
    
    var ref = Database.database().reference()
    
    func loadGameTypes(gameTypes: @escaping (_: [GameType]) -> Void) {
        ref.child("Game Types").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            DispatchQueue.main.async {
                guard let jsonDictionary = dataSnapshot.value as? [String: [String: Any]] else { gameTypes([]); return }
                
                let gameTypeArray = jsonDictionary.flatMap { GameType(dictionary: $0.1) }
                
                let sortedGameTypes = gameTypeArray.sorted { $0.sortOrder < $1.sortOrder }
                
                gameTypes(sortedGameTypes)
            }
        })
    }
    
    func loadGameTypes(from url: URL?, gameTypes: @escaping (_: [GameType]) -> Void) {
        
        var unwrapedURL: URL
        
        if url == nil {
            unwrapedURL = gameTypeURL!
        } else {
            unwrapedURL = url!
        }
        
        NetworkController.performRequest(for: unwrapedURL, httpMethod: .get, urlParameters: nil, body: nil) { (jsonData, error) in
            DispatchQueue.main.async {
                
                guard let data = jsonData, error == nil else { gameTypes([]); return}
                guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: [String: Any]] else { gameTypes([]); return }
                
                let gameTypeArray = jsonDictionary.flatMap { GameType(dictionary: $0.1) }
                
                let sortedGameTypes = gameTypeArray.sorted { $0.sortOrder < $1.sortOrder }
                
                gameTypes(sortedGameTypes)
                
            }
        }
    }
}
