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
    
    var imageNames: [String] {
        var tempArray: [String] = []
        guard loadedGameTypes.count != 0 else { return [] }
        for gametype in loadedGameTypes {
            tempArray.append(gametype.imageName)
        }
        return tempArray
    }
    
    static let shared = FirebaseController()
    
    var storage = Storage.storage()
    var folderRef = Storage.storage().reference().child("GameTypeImages")
    
    func createFolderReferences(folderReferences: @escaping ([String: StorageReference?]) -> Void) {
        
        var folders: [String: StorageReference?] = [:]
        
        DispatchQueue.main.async {
            
            guard loadedGameTypes.count != 0 else { folderReferences([:]); return }
            
            for imageName in self.imageNames {
                folders[imageName] = self.folderRef.child(imageName)
            }
            
            folderReferences(folders)
            return
        }
    }
    
    func getGameTypeImages(images: @escaping ([String: UIImage]) -> Void) {
        
        var loadedGameTypeImages: [String : UIImage] = [:]
        
        createFolderReferences { (foldersRefs) in
            DispatchQueue.main.async {
                if foldersRefs.count == 0 {
                    images([:])
                    print("Failed to load game type images")
                    return
                } else {
                    for folder in foldersRefs {
                        folder.value?.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                            guard let data = data, error == nil else { print(error?.localizedDescription ?? "Error loaded image for folder \(folder.key)"); images([:]); return }
                            guard let image = UIImage.init(data: data) else { return }
                            loadedGameTypeImages[folder.key] = image
                            if  loadedGameTypeImages.count == foldersRefs.count {
                                images(loadedGameTypeImages)
                            }
                        }
                    }
                }
            }
        }
    }
 }
 
