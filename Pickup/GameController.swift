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
        let urlWithUUID = endUrl?.appendingPathComponent("Games").appendingPathComponent(withUUID.uuidString).appendingPathExtension("json")
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
}
