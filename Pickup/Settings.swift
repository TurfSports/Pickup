//
//  Settings.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/7/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation


class Settings {
    
    class var sharedSettings: Settings {
        
        struct Singleton {
            static let instance = Settings()
        }
        
        return Singleton.instance
    }
    
    var gameDistance = 10
    var distanceUnit = "miles"
    var gameReminder = 0
    var defaultLocation = "none"
    var showCreatedGames = true
    
    init () {}
    
    
    
    static func serializeSettings(settings: Settings) -> [String: String] {
        var serializedSettings: [String: String] = [:]
        
        serializedSettings["GameDistance"] = "\(settings.gameDistance)"
        serializedSettings["DistanceUnit"] = settings.distanceUnit
        serializedSettings["GameReminder"] = "\(settings.gameReminder)"
        serializedSettings["DefaultLocation"] = settings.defaultLocation
        
        if settings.showCreatedGames == true {
            serializedSettings["ShowCreatedGames"] = "1"
        } else {
            serializedSettings["ShowCreatedGames"] = "0"
        }
        
        return serializedSettings
    }
    
    static func deserializeSettings(serializedSettings: [String: String]) -> Settings  {
        
        let settings = Settings.init()
        
        settings.gameDistance = Int(serializedSettings["GameDistance"]!)!
        settings.distanceUnit = serializedSettings["DistanceUnit"]!
        settings.gameReminder = Int(serializedSettings["GameReminder"]!)!
        settings.defaultLocation = serializedSettings["DefaultLocation"]!
        
        let showCreatedGames = Int(serializedSettings["ShowCreatedGames"]!)!

        if showCreatedGames == 1 {
            settings.showCreatedGames = true
        } else {
            settings.showCreatedGames = false
        }
        
        return settings
    }
}

