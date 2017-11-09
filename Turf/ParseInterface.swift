//
//  ParseInterface.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/29/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class ParseInterface {
    
    func getGameTypes() -> Void {
//        let query = PFQuery(className:"GameType")
//        query.getObjectInBackgroundWithId("clvB6p88Ur") {
//            (gameScore: PFObject?, error: NSError?) -> Void in
//            if error == nil && gameScore != nil {
//                
//                
//                print(gameScore)
//            } else {
//                print(error)
//            }
//        }
        
        let query = PFQuery(className:"GameType")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        print(object.objectId)
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    
    
}
