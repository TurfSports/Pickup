//
//  Settings.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/7/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation


class Settings {
    
    static var shared = Settings()
    
    var gameDistance = 10
    var distanceUnit = "miles"
    var gameReminder = 0
    var defaultLocation = "none"
    var defaultLatitude = 40.247015
    var defaultLongitude = -111.640160
    var showCreatedGames = true
    
    static func saveSettings(_ settings: [String: String]) {
        UserDefaults.standard.set(settings, forKey: "Settings")
    }
    
    static func loadSettings() {
        guard let userSettings = UserDefaults.standard.dictionary(forKey: "Settings") else { return }
        self.shared = deserializeSettings(userSettings)
    }
    
    static func serializeSettings(_ settings: Settings) -> [String: String] {
        var serializedSettings: [String: String] = [:]
        
        serializedSettings["GameDistance"] = "\(settings.gameDistance)"
        serializedSettings["DistanceUnit"] = settings.distanceUnit
        serializedSettings["GameReminder"] = "\(settings.gameReminder)"
        serializedSettings["DefaultLocation"] = settings.defaultLocation
        serializedSettings["DefaultLatitude"] = "\(settings.defaultLatitude)"
        serializedSettings["DefaultLongitude"] = "\(settings.defaultLongitude)"
        serializedSettings["ShowCreatedGames"] = (settings.showCreatedGames ? "1" : "0")

        
        return serializedSettings
    }
    
    static func deserializeSettings(_ serializedSettings: [String: Any]) -> Settings  {
        
        let settings = Settings.init()
        
        guard let gameDistance = serializedSettings["GameDistance"] as? Int,
        let distanceUnit = serializedSettings["DistanceUnit"] as? String,
        let gameReminder = serializedSettings["GameReminder"] as? Int,
        let defaultLocation = serializedSettings["DefaultLocation"] as? String,
        let defaultLatitude = serializedSettings["DefaultLatitude"] as? Double,
        let defaultLongitude = serializedSettings["DefaultLongitude"] as? Double,
        let showCreatedGames = serializedSettings["ShowCreatedGames"] as? Int
        
            else { return settings }
        
        settings.gameDistance = gameDistance
        settings.distanceUnit = distanceUnit
        settings.gameReminder = gameReminder
        settings.defaultLocation = defaultLocation
        settings.defaultLatitude = defaultLatitude
        settings.defaultLongitude = defaultLongitude
        settings.showCreatedGames = showCreatedGames == 1
        
        return settings
    }
}

