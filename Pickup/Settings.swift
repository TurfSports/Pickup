//
//  Settings.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/7/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import CoreLocation

class Settings {
    
    static var shared = Settings()
    
    var gameDistance = 10
    var distanceUnit = "miles"
    var gameReminder = 0
    var defaultLocation = "none"
    var userLocation: CLLocation?
    var defaultLatitude = 40.247015
    var defaultLongitude = -111.640160
    var showCreatedGames = true

    init() {
        
    }
    
    init(gameDistance: Int?, distanceUnit: String?, gameReminder: Int?, userLocation: CLLocation?, defaultLocation: String?, defaultLatitude: Double?, defaultLongitude: Double?, showCreatedGames: Bool?) {
        self.gameDistance = gameDistance ?? 10
        self.distanceUnit = distanceUnit ?? "miles"
        self.gameReminder = gameReminder ?? 0
        self.defaultLocation = defaultLocation ?? "none"
        self.defaultLatitude = defaultLatitude ?? 40.247015
        self.defaultLongitude = defaultLongitude ?? -111.64016
        self.showCreatedGames = showCreatedGames ?? true
    }
    
    static func saveSettings(_ settings: [String: Any]) {
        UserDefaults.standard.set(settings, forKey: "Settings")
    }
    
    static func loadSettings() {
        guard let userSettings = UserDefaults.standard.dictionary(forKey: "Settings") else { return }
        self.shared = deserializeSettings(userSettings)
    }
    
    static func serializeSettings(_ settings: Settings) -> [String: Any] {
        var serializedSettings: [String: Any] = [:]
        
        serializedSettings["GameDistance"] = settings.gameDistance
        serializedSettings["DistanceUnit"] = settings.distanceUnit
        serializedSettings["GameReminder"] = settings.gameReminder
        serializedSettings["DefaultLocation"] = settings.defaultLocation
        serializedSettings["DefaultLatitude"] = settings.defaultLatitude
        serializedSettings["DefaultLongitude"] = settings.defaultLongitude
        serializedSettings["ShowCreatedGames"] = settings.showCreatedGames ? true : false

        
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
        let showCreatedGames = serializedSettings["ShowCreatedGames"] as? Bool
        
            else { return settings }
        
        settings.gameDistance = gameDistance
        settings.distanceUnit = distanceUnit
        settings.gameReminder = gameReminder
        settings.defaultLocation = defaultLocation
        settings.defaultLatitude = defaultLatitude
        settings.defaultLongitude = defaultLongitude
        settings.showCreatedGames = showCreatedGames
        
        return settings
    }
}

