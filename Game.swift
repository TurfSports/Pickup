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
    
    private let kGameType:String = "GameType"
    private let kTotalSlots:String = "Total Slots"
    private let kAvailableSlots:String = "Available Slots"
    private let kEventDate:String = "Event Date"
    private let kLocationName:String = "Location Name"
    private let kOwnerId:String = "Owner ID"
    private let kGameNotes:String = "Game Notes"
    private let kUserJoined:String = "User Joined Bool"
    private let kUserIsOwner:String = "User Is Owner Bool"
    private let kIsCancelled:String = "Is Cancelled Bool"
    private let kLatitude:String = "Latitude"
    private let kLongitude:String = "Longitude"
    
    var id:String
    var gameType:GameType
    var totalSlots:Int
    var availableSlots:Int
    var eventDate:Date
    var locationName:String
    var ownerId:String
    var gameNotes:String
    lazy var userJoined = false
    lazy var userIsOwner = false
    lazy var isCancelled = false
    lazy var latitude:Double = 0.0
    lazy var longitude:Double = 0.0
    
    init (id: String, gameType: GameType, totalSlots: Int,
        availableSlots: Int, eventDate: Date, locationName: String,
        ownerId: String, gameNotes: String) {
        self.id = id
        self.gameType = gameType
        self.totalSlots = totalSlots
        self.availableSlots = availableSlots
        self.eventDate = eventDate
        self.locationName = locationName
        self.ownerId = ownerId
        self.gameNotes = gameNotes
    }
    
    func setCoordinates (_ latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: gameDictionary, options: .prettyPrinted)
    }
    
    var gameDictionary: [String: Any] {
        
        let eventDateString = String(describing: eventDate)
        
        return [kGameType: gameType.dictionaryRep, kTotalSlots: totalSlots, kAvailableSlots: availableSlots, kEventDate: eventDateString, kLocationName: locationName, kOwnerId: ownerId, kGameNotes: gameNotes, kUserJoined: userJoined, kUserIsOwner: userIsOwner, kIsCancelled: isCancelled, kLatitude: latitude, kLongitude: longitude]
    }
}

enum GameKeys {
    case kGameType = "GameType"
    case kTotalSlots = "Total Slots"
    case kAvailableSlots = "Available Slots"
    case kEventDate = "Event Date"
    case kLocationName = "Location Name"
    case kOwnerId = "Owner ID"
    case kGameNotes = "Game Notes"
    case kUserJoined = "User Joined Bool"
    case kUserIsOwner = "User Is Owner Bool"
    case kIsCancelled = "Is Cancelled Bool"
    case kLatitude = "Latitude"
    case kLongitude = "Longitude"
}
