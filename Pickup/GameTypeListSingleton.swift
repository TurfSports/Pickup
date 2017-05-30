//
//  GameTypeListSingleton.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/8/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class GameTypeList {
    
    static let shared = GameTypeList()
    
    var gameTypeList: [GameType] = []
    
    func setGameTypeList(_ gameTypeList: [GameType]) {
        self.gameTypeList = gameTypeList
    }
    
    func getGameTypeById(_ id: String) -> GameType? {
        
        for gameType in self.gameTypeList {
            if gameType.id == id {
                return gameType
            }
        }
        
        return nil
        
    }
    
    
    
}
