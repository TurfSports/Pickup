//
//  Game.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/22/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation


class Game {
    
    let id:String
    var gameSizeInPlayers:Int
    var availableSlots:Int
    var eventDate:NSDate
    var owner:Player
    var location:Int
    
    lazy var players:[String: Player] = [:]
    
    init (id: String, gameSizeInPlayers: Int, availableSlots: Int, eventDate: NSDate, owner: Player, location: Int) {
        self.id = id
        self.gameSizeInPlayers = gameSizeInPlayers
        self.availableSlots = availableSlots
        self.eventDate = eventDate
        self.owner = owner
        self.location = location
    }
    
}