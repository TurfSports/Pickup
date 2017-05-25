//
//  GameTypeConverter.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/8/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class GameTypeConverter {
    

    static func convertParseObject (_ gameTypeObject: [String: Any]) -> GameType {
        
        let id = gameTypeObject.first?.key
        let name = gameTypeObject["name"] as! String
        let displayName = gameTypeObject["displayName"] as! String
        let sortOrder = gameTypeObject["sortOrder"] as! Int
        let imageName = gameTypeObject["imageName"] as! String
        
        let gameType = GameType.init(id: id!, name: name, displayName: displayName, sortOrder: sortOrder, imageName: imageName)
        
        return gameType
    }
    
}

