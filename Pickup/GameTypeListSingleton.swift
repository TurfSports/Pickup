//
//  GameTypeListSingleton.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/8/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class GameTypeList {
    
    class var sharedGameTypes: GameTypeList {
        
        struct Singleton {
            static let instance = GameTypeList()
        }
        
        return Singleton.instance
    }
    
    var gameTypeList: [GameType] = []
    
    init() {}
    
    
    func setGameTypeList(gameTypeList: [GameType]) {
        self.gameTypeList = gameTypeList
    }
    
    func getGameTypeById(id: String) -> GameType? {
        
        for gameType in self.gameTypeList {
            if gameType.id == id {
                return gameType
            }
        }
        
        return nil
        
    }
    
    
    
}
