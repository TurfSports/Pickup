//
//  DummyDataController.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/22/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class DummyDataController {
    
    lazy var games:[String: Game] = [:]
    lazy var players:[String: Player] = [:]
    lazy var gameType:[String: GameType] = [:]
    
    init () {
        let player1:Player = Player.init(username: "ndudley")
        let player2:Player = Player.init(username: "jcarlson")
        let player3:Player = Player.init(username: "johnnyk")
        let player4:Player = Player.init(username: "cougarfan")
        let player5:Player = Player.init(username: "cschow3")
        let player6:Player = Player.init(username: "malik")
        
        
        players["\(player1.username)"] = player1
        players["\(player2.username)"] = player2
        players["\(player3.username)"] = player3
        players["\(player4.username)"] = player4
        players["\(player5.username)"] = player5
        players["\(player6.username)"] = player6

        
        let basketball:GameType = GameType.init(id: "1", name: "basketball", displayName: "Baksetball", sortOrder: 1, imageName: "basketball.jpg")
        let soccer:GameType = GameType.init(id: "1", name: "soccer", displayName: "Soccer", sortOrder: 2, imageName: "soccer.jpg")
        let baseball:GameType = GameType.init(id: "1", name: "baseball", displayName: "Baseball", sortOrder: 3, imageName: "baseball.jpg")
        
        gameType["\(basketball.id)"] = basketball
        gameType["\(soccer.id)"] = soccer
        gameType["\(baseball.id)"] = baseball
        
        
        let game1: Game = Game.init(id: "100", gameSizeInPlayers: 20, availableSlots: 3, eventDate: NSDate(), owner: player1, location: 5)
        let game2: Game = Game.init(id: "200", gameSizeInPlayers: 15, availableSlots: 6, eventDate: NSDate(), owner: player2, location: 7)
        
        games[game1.id] = game1
        games[game2.id] = game2
        
    }
    
}