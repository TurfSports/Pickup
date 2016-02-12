//
//  GameConverter.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/8/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import Parse

class GameConverter {
    
    static func convertParseObject(gameObject: PFObject, selectedGameType: GameType) -> Game {
     
        
        let id = gameObject.objectId!
        let gameType = selectedGameType
        let totalSlots = gameObject["totalSlots"] as! Int
        let availableSlots = gameObject["slotsAvailable"] as! Int
        let eventDate = gameObject["date"] as! NSDate
        let locationName = gameObject["locationName"] as! String
//        let owner = gameObject["owner"] as? String
        let latitude =  gameObject["location"]!.latitude
        let longitude = gameObject["location"]!.longitude
        let game = Game.init(id: id, gameType: gameType, totalSlots: totalSlots, availableSlots: availableSlots, eventDate: eventDate, locationName: locationName)
        
        game.setCoordinates(latitude, longitude: longitude)
        
        
        return game
    }
    
}
