//
//  Game.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/22/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import CoreLocation



class Game {
    
    let id:String
    var gameType:GameType
    var totalSlots:Int
    var availableSlots:Int
    var eventDate:NSDate
//    lazy var owner:Player
    lazy var latitude:Double = 0.0
    lazy var longitude:Double = 0.0
    
//    lazy var players:[String: Player] = [:]
    
    init (id: String, gameType: GameType, totalSlots: Int,
        availableSlots: Int, eventDate: NSDate) {
        self.id = id
        self.gameType = gameType
        self.totalSlots = totalSlots
        self.availableSlots = availableSlots
        self.eventDate = eventDate
    }
    
    func setCoordinates (latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
//    func setOwner 
    
}