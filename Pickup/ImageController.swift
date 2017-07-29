//
//  ImageController.swift
//  Pickup
//
//  Created by Justin Carver on 7/11/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import Foundation
import UIKit

class ImageController {
        
    static func imageForURL(url: String, completion: @escaping ((_ image: UIImage?) -> Void)) {
        
        guard let url = URL(string: url) else { fatalError("Image URl optional is nil") }
        
        
        
        NetworkController.performRequest(for: url, httpMethod: .get) { (data, error) in
            guard let data = data else { completion(nil); return }
            
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
    }
}
