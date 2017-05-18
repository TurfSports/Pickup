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
import FirebaseStorage

class FirebaseController {
    
    let folderRef = FIRStorage.storage().reference(forURL: "https://pickup-a837a.firebaseio.com/")
    
    static let shared = FirebaseController()
    
    func save(game: Game, with UUID: UUID, success: @escaping (Bool) -> Void) {
        game.id = UUID.uuidString
        guard game.jsonData != nil else { success(false); return }
        folderRef.put(game.jsonData!)
        DispatchQueue.main.async {
            success(true)
            return
        }
    }
}
