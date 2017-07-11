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
    var imageFolders: [StorageReference] = []
    var images: [UIImage] = []
    
    static let shared = FirebaseController()
    
    func save(game: Game, with UUID: UUID, success: @escaping (Bool) -> Void) {
        game.id = UUID.uuidString
        guard game.jsonData != nil else { success(false); return }
        DispatchQueue.main.async {
            success(true)
            return
        }
    }
    
    func createFolderReferences(sucess: @escaping (Bool) -> Void) {
        let gameTypeImageFolderRef = folderRef.child("GameTypeImages")
        imageFolders.append(gameTypeImageFolderRef.child("basketball.png"))
        imageFolders.append(gameTypeImageFolderRef.child("baseball.png"))
        imageFolders.append(gameTypeImageFolderRef.child("frisbee.png"))
    }
    
    func getGameTypeImages(gotImages: @escaping (Bool) -> Void) {
        
        createFolderReferences { (success) in
            if !success {
                gotImages(false)
                return
            }
        }
        
        for folderRef in imageFolders {
            folderRef.getData(maxSize: Int64.init(100)) { (data, error) in
                guard let data = data, error == nil else { gotImages(false); print("Failed to load game type images"); return }
                guard let image = UIImage.init(data: data) else { gotImages(false); return }
                self.images.append(image)
                print("Loaded game type images \(data)")
            }
        }
    }
}

