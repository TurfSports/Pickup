//
//  Theme.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/25/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit

struct Theme {
    
    static let primaryColor:UIColor = UIColor(red: 96.0/255.0, green: 125.0/255.0, blue: 139.0/255.0, alpha: 1.0)
    static let primaryDarkColor:UIColor = UIColor(red: 69.0/255, green: 90.0/255, blue: 100/255.0, alpha: 1.0)
    static let primaryLightColor:UIColor = UIColor(red: 207.0/255, green: 216.0/255, blue: 220.0/255, alpha: 1.0)
    static let testColor:UIColor = UIColor(red: 179.0/255, green: 96.0/255, blue: 125.0/255, alpha: 1.0)
 
    static func applyTheme() {
        let sharedApplication = UIApplication.sharedApplication()
        sharedApplication.delegate?.window??.tintColor = primaryLightColor
        UINavigationBar.appearance().barTintColor = primaryDarkColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UITableView.appearance().backgroundColor = primaryLightColor
    }
    
}

