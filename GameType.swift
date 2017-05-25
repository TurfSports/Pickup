//
//  GameType.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/21/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class GameType {
    
    private let kName = "name"
    private let kdisplayName = "displayName"
    private let ksortOrder = "sortOrder"
    private let kimageName = "imageName"
    
    let id:String
    let name:String
    let displayName:String
    var sortOrder:Int
    let imageName:String
    
    var gameCount:Int = -1
    
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
    
    var dictionaryRep: [String: Any] {
        return [id: [kName: name, ksortOrder: sortOrder, kimageName: imageName, kdisplayName: displayName]]
    }
    
}

enum GameTypeKeys {
    case kName
    case kdisplayName
    case ksortOrder
    case kimageName
    
    func key() -> String {
        switch self {
        case .kName:
            return "name"
        case .kdisplayName:
            return "displayName"
        case .ksortOrder:
            return "sortOrder"
        case .kimageName:
            return "imageName"
        }
    }
}
