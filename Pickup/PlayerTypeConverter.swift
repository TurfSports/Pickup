//
//  PlayerTypeConverter.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/13/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import Parse

class PlayerTypeConverter {
    
    static func convertParseObject (playerObject: PFUser) -> Player {
        
        let id = playerObject.objectId!
        let username = playerObject.username!
        
        let player = Player.init(id: id, username: username)
        
        return player
    }
    
}
