//
//  FirebaseController.swift
//  Pods
//
//  Created by Justin Carver on 5/18/17.
//
//

import Foundation
import UIKit
import Firebase

class FirebaseController {
    
    let user = "0"
    
    let folderRef = FIRStorage.storage().reference(forURL: "https://pickup-a837a.firebaseio.com/").child(user)
    
    static let shared = FirebaseController()
    
    func save(game: Game, with UUID: UUID, success: @escaping (Bool) -> Void) {
        game.id = UUID.uuidString
        folderRef.put(game)
        DispatchQueue.main.async {
            success(true)
            return
        }
    }
}
