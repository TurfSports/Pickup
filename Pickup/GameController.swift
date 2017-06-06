//
//  GameController.swift
//  Pickup
//
//  Created by Justin Carver on 5/23/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import Foundation

class GameController {
    
    static let endUrl = URL.init(string: "https://pickup-a837a.firebaseio.com")
    
    static func put(game: Game, withUUID: UUID, success: @escaping (_ success: Bool) -> Void) {
        let urlWithUUID = endUrl?.appendingPathComponent("Games").appendingPathComponent(game.id).appendingPathExtension("json")
        guard let url = urlWithUUID else { success(false); return }
        
        NetworkController.performRequest(for: url, httpMethod: .put, body: game.jsonData) { (data, error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                    success(false)
                    return
                } else {
                    success(true)
                    print("Put Game Info")
                    return
                }
            }
        }
    }
    
    static let gameURL = URL(string: "https://pickup-a837a.firebaseio.com/Games")
    
    static func loadGames(completion: @escaping (_ games: [Game]) -> Void) {
        var gameArray: [Game] = []
        guard let url = GameController.gameURL else { completion([]); return }
        NetworkController.performRequest(for: url, httpMethod: .get, urlParameters: nil, body: nil) { (data, error) in
            DispatchQueue.main.async {
                guard data != nil && error == nil else { completion([]); return }
                guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as? [[String: Any]] else { completion([]); return }
                
                for game in jsonDictionary {
                    gameArray.append(Game(gameDictionary: game)!)
                }
                completion(gameArray)
            }
        }
    }
}
