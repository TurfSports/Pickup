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
    
    static func convertParseObject(_ gameObject: PFObject, selectedGameType: GameType) -> Game {
     
        
        let id = gameObject.objectId!
        let gameType = selectedGameType
        let availableSlots = gameObject["slotsAvailable"] as! Int
        let totalSlots = gameObject["totalSlots"] as! Int
        let eventDate = gameObject["date"] as! Date
        let locationName = gameObject["locationName"] as! String
        let owner = (gameObject["owner"] as AnyObject).objectId!
        let gameNotes = gameObject["gameNotes"] as! String
        let latitude =  (gameObject["location"]! as AnyObject).latitude
        let longitude = (gameObject["location"]! as AnyObject).longitude
        let game = Game.init(id: id, gameType: gameType, totalSlots: totalSlots, availableSlots: availableSlots, eventDate: eventDate, locationName: locationName, ownerId: owner!, gameNotes: gameNotes)
        
        game.setCoordinates(latitude!, longitude: longitude!)
        
        return game
    }
    
}
