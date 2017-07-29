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
    
    let folderRef = Storage.storage().reference(forURL: "gs://pickup-a837a.appspot.com/")
    
    static let shared = FirebaseController()
    
    func save(game: Game, with UUID: UUID, success: @escaping (Bool) -> Void) {
        game.id = UUID.uuidString
        guard game.jsonData != nil else { success(false); return }
        DispatchQueue.main.async {
            success(true)
            return
        }
    }
}
