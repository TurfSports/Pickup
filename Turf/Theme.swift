//
//  Theme.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/25/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit

struct Theme {
    
    static let PRIMARY_COLOR:UIColor = UIColor(red: 96.0/255.0, green: 125.0/255.0, blue: 139.0/255.0, alpha: 1.0)
    static let PRIMARY_DARK_COLOR:UIColor = UIColor(red: 69.0/255, green: 90.0/255, blue: 100/255.0, alpha: 1.0)
    static let PRIMARY_DARK_NAV_COLOR:UIColor = UIColor(red: 69.0/255, green: 90.0/255, blue: 100/255.0, alpha: 0.5)
    static let PRIMARY_LIGHT_COLOR:UIColor = UIColor(red: 207.0/255, green: 216.0/255, blue: 220.0/255, alpha: 1.0)
    static let ACCENT_COLOR:UIColor = UIColor(red:205.0/255, green:220.0/255, blue: 57.0/255, alpha: 1.0)
    static let ERROR_FLASH_COLOR:UIColor = UIColor(red: 255.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.25)
    static let ERROR_COLOR:UIColor = UIColor(red: 255.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.15)
    static let UNEDITABLE_CELL_COLOR:UIColor = UIColor(red: 207.0/255, green: 216.0/255, blue: 220.0/255, alpha: 0.7)
    
    static let GAME_TYPE_CELL_HEIGHT = CGFloat(100.00)
    static let GAME_LIST_ROW_HEIGHT = CGFloat(96.00)
 
    static func applyTheme() {
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = PRIMARY_DARK_COLOR
        UINavigationBar.appearance().barTintColor = PRIMARY_DARK_NAV_COLOR
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    static func applyThemeToCell(_ cell: HomeTableViewCell) {
        cell.backgroundColor = UIColor.white
        let bgColorView = UIView()
        bgColorView.backgroundColor = PRIMARY_LIGHT_COLOR
        cell.selectedBackgroundView = bgColorView
    }
    
}

