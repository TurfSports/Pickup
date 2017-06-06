//
//  GameType.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/21/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class GameType {
    
    private let kGameTypeID = "gameTypeID"
    private let kName = "name"
    private let kDisplayName = "displayName"
    private let kSortOrder = "sortOrder"
    private let kImageName = "imageName"
    
    var id: String = UUID.init().uuidString
    var name: String = ""
    var displayName: String = ""
    var sortOrder: Int = 0
    var imageName: String = ""
    
    var gameCount: Int = -1
    
    init(id: String, name: String, displayName: String, sortOrder: Int, imageName: String) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.sortOrder = sortOrder
        self.imageName = imageName
        self.gameCount = 0
    }
    
    func setGameCount(_ count: Int) {
        gameCount = count
    }
    
    func increaseGameCount(_ count: Int) {
        gameCount += count
    }

    static func serializeGameType(_ game: GameType) -> [String: String] {
        var serializedGameType: [String: String] = [:]
        
        serializedGameType["id"] = game.id
        serializedGameType["name"] = game.name
        serializedGameType["displayName"] = game.displayName
        serializedGameType["sortOrder"] = "\(game.sortOrder)"
        serializedGameType["imageName"] = game.imageName
        
        return serializedGameType
    }
    
    static func deserializeGameType(_ serializedGameType: [String: String]) -> GameType  {
        
        let id = serializedGameType["id"]
        let name = serializedGameType["name"]
        let displayName = serializedGameType["displayName"]
        let sortOrder = Int(serializedGameType["sortOrder"]!)
        let imageName = serializedGameType["imageName"]
        
        let gameType = GameType.init(id: id!, name: name!, displayName: displayName!, sortOrder: sortOrder!, imageName: imageName!)
        
        return gameType
    }

    init?(dictionary: [String: Any]) {
        guard let name = dictionary[kName] as? String,
        let displayName = dictionary[kDisplayName] as? String,
        let imageName = dictionary[kImageName] as? String,
        let sortOrder = dictionary[kSortOrder] as? Int
        else { return }
    
        self.name = name
        self.displayName = displayName
        self.imageName = imageName
        self.sortOrder = sortOrder
    }
    
    var dictionaryRep: [String: Any] {
        return [kGameTypeID: id, kName: name, kSortOrder: sortOrder, kImageName: imageName, kDisplayName: displayName]
    }
    
}
