//
//  GameDetailsTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/23/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import MapKit

class GameDetailsTableViewController: UITableViewController {

    @IBOutlet weak var lblGameNotes: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var btnOpenMaps: UIButton!
    @IBOutlet weak var btnAddToCalendar: UIButton!
    
    var game: Game!
    
    var address: String! {
        didSet {
            lblAddress.text = address
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnOpenMaps.tintColor = Theme.PRIMARY_DARK_COLOR
        btnAddToCalendar.tintColor = Theme.PRIMARY_DARK_COLOR
        
        lblGameNotes.text = game.gameNotes
        lblGameNotes.sizeToFit()
        
        lblDay.text = DateUtilities.dateString(game.eventDate, dateFormatString: DateFormatter.MONTH_DAY_YEAR.rawValue)
        lblTime.text = DateUtilities.dateString(game.eventDate, dateFormatString: DateFormatter.TWELVE_HOUR_TIME.rawValue)
        lblAddress.text = ""
        
        let geoCoder = CLGeocoder()
        let gameLocation = CLLocation(latitude: game.latitude, longitude: game.longitude)
        
        geoCoder.reverseGeocodeLocation(gameLocation, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            self.address = ""
            
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                self.address = self.address + "\(locationName)"
            }
            
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                self.address = self.address + "\n\(city)"
                
            }
            
            if let state = placeMark.addressDictionary!["State"] as? NSString {
                self.address = self.address + ", \(state)"
                
            }
            
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                self.address = self.address + " \(zip)"
                
            }
            
        })
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
