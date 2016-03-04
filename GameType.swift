//
//  GameType.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/21/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class GameType {
    
    let id:String
    let name:String
    let displayName:String
    var sortOrder:Int
    let imageName:String
    
    var gameCount:Int
    
    init (id: String, name: String, displayName: String, sortOrder: Int, imageName: String) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.sortOrder = sortOrder
        self.imageName = imageName
        self.gameCount = 0
    }
    
    func setGameCount(count: Int) {
        gameCount = count
    }

    
    static func serializeGameType(game: GameType) -> [String: String] {
        var serializedGameType: [String: String] = [:]
        
        serializedGameType["id"] = game.id
        serializedGameType["name"] = game.name
        serializedGameType["displayName"] = game.displayName
        serializedGameType["sortOrder"] = "\(game.sortOrder)"
        serializedGameType["imageName"] = game.imageName
        
        return serializedGameType
    }
    
    static func deserializeGameType(serializedGameType: [String: String]) -> GameType  {
        
        let id = serializedGameType["id"]
        let name = serializedGameType["name"]
        let displayName = serializedGameType["displayName"]
        let sortOrder = Int(serializedGameType["sortOrder"]!)
        let imageName = serializedGameType["imageName"]
        
        let gameType = GameType.init(id: id!, name: name!, displayName: displayName!, sortOrder: sortOrder!, imageName: imageName!)
        
        return gameType
    }
    
}