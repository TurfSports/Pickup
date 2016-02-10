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
    
    static func convertParseObject(gameObject: PFObject) -> Game {
     
        let id = gameObject.objectId!
        let gameType = GameTypeConverter.convertParseObject((gameObject["gameType"] as? PFObject)!)
        let totalSlots = gameObject["totalSlots"] as! Int
        let availableSlots = gameObject["availableSlots"] as! Int
        let eventDate = gameObject["date"] as! NSDate
//        let owner = gameObject["owner"] as? String
        let latitude =  gameObject["location"]!.latitude
        let longitude = gameObject["location"]!.longitude
        
        let game = Game.init(id: id, gameType: gameType, totalSlots: totalSlots, availableSlots: availableSlots, eventDate: eventDate)
        
        game.setCoordinates(latitude, longitude: longitude)
        
        
        return game
    }
    
//        let id:String
//        var gameType:GameType
//        var gameSizeInPlayers:Int
//        var availableSlots:Int
//        var eventDate:NSDate
//        var owner:Player
//        var location:Int
//        
//        
//        lazy var players:[String: Player] = [:]
//        
//        init (id: String, gameType: GameType, gameSizeInPlayers: Int,
//            availableSlots: Int, eventDate: NSDate, owner: Player, location: Int) {
//                self.id = id
//                self.gameType = gameType
//                self.gameSizeInPlayers = gameSizeInPlayers
//                self.availableSlots = availableSlots
//                self.eventDate = eventDate
//                self.owner = owner
//                self.location = location
//        }
        
    
}
