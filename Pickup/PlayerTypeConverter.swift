//
//  PlayerTypeConverter.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/13/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class PlayerTypeConverter {
    
    static func convertParseObject (_ playerDictionary: [String: Any]) -> Player {
        
        let id = playerDictionary.first?.key
        let username = playerDictionary["username"] as? String
        
        guard id != nil, username != nil else { return Player(id: "_userID", username: "username") }
        
        let player = Player.init(id: id!, username: username!)
        
        return player
    }
    
}
