//
//  GameTypeController.swift
//  Pickup
//
//  Created by Justin Carver on 5/31/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import Foundation

class GameTypeController {
    
    static let jsonURL = URL(string: "https://pickup-a837a.firebaseio.com/Game%20Types.json")
    
    static func loadGameTypes(gameTypes: @escaping (_: [GameType]) -> Void) {
        guard let url = jsonURL else { gameTypes([]); return }
        NetworkController.performRequest(for: url, httpMethod: .get, urlParameters: nil, body: nil) { (jsonData, error) in
            DispatchQueue.main.async {
                
                guard let data = jsonData, error == nil else { gameTypes([]); return}
                guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: [String: Any]] else { gameTypes([]); return }
                
                let gameTypeArray = jsonDictionary.flatMap { GameType(dictionary: $0.1) }
                
                gameTypes(gameTypeArray)
                
            }
        }
    }
}
