//
//  GameDetailsTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/23/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import MapKit
import EventKit

class GameDetailsTableViewController: UITableViewController {

    @IBOutlet weak var lblGameNotes: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var btnOpenMaps: UIButton!
    @IBOutlet weak var btnAddToCalendar: UIButton!


    var parentDelegate: GameDetailsViewDelegate!
    var game: Game!
    var isOwner: Bool = false
    
    var address: String! {
        didSet {
            parentDelegate.setGameAddress(address)
            lblAddress.text = address
        }
    }
    
    @IBAction func addToCalendar(sender: UIButton) {
        insertGameIntoCalendar()
        UIApplication.sharedApplication().openURL(NSURL(string: "calshow:\(game.eventDate.timeIntervalSinceReferenceDate)")!)
    }
    
    @IBAction func openInMaps(sender: UIButton) {
        openMapsForPlace()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAddToCalendar.hidden = true

        btnOpenMaps.tintColor = Theme.ACCENT_COLOR
        btnAddToCalendar.tintColor = Theme.ACCENT_COLOR
        
        self.tableView.tableFooterView = UIView.init(frame: CGRectZero)
        
        if game.userJoined == true {
            btnAddToCalendar.hidden = false
        }
        
        lblGameNotes.text = game.gameNotes
        if game.gameNotes == "" {
            lblGameNotes.text = "No notes for this game"
        }
        
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

        var height = UITableViewAutomaticDimension
        
        if indexPath.section == 3 && indexPath.row == 0 {
            if isOwner == false {
                height = 0.0
            } else {
                height = 44.0
            }
        }
        

        return height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension

    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height:CGFloat = 5.0
        if section == 0 {
            height = 0
        }
        
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 3 && indexPath.row == 0 {
            parentDelegate.cancelGame(self.game)
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        cell?.userInteractionEnabled = false
        cell?.selectionStyle = .None
        
        if indexPath.section == 3 && indexPath.row == 0 {
            cell?.userInteractionEnabled = true
            cell?.selectionStyle = .Gray
        }
        
        return indexPath
        
    }
    
    func insertGameIntoCalendar () -> String {
        
        var resultString = ""
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatusForEntityType(.Event) {
        case .Authorized:
            insertEvent(eventStore)
            resultString = "Access granted to event store"
        case .Denied:
            resultString = "Access denied to event store"
        case .NotDetermined:
            eventStore.requestAccessToEntityType(.Event, completion:
                {[weak self] (granted: Bool, error: NSError?) -> Void in
                    if granted {
                        self!.insertEvent(eventStore)
                    } else {
                        resultString = "Access denied to event store"
                    }
                })
        default:
            resultString = "Default"
        }
        
        print (resultString)
        return resultString
        
    }
    
    
    func insertEvent(store: EKEventStore) {

        let calendars = store.calendarsForEntityType(.Event)

        let event = EKEvent(eventStore: store)
        
        for calendar in calendars {
            if calendar.allowsContentModifications {
                print(calendar.title)
                event.calendar = calendar
                event.title = "\(game.gameType.displayName) at \(game.locationName)"
                event.startDate = game.eventDate
                event.endDate = game.eventDate.dateByAddingTimeInterval(1.5 * 60 * 60)
                
                do {
                    try store.saveEvent(event, span: .ThisEvent)
                } catch let error as NSError {
                    print("ERROR: \(error)")
                } catch {
                    print("Calendar add not working")
                }
                
                break
            }
        }

    }
    
    func openMapsForPlace() {
        
        let latitute:CLLocationDegrees =  game.latitude
        let longitute:CLLocationDegrees =  game.longitude
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(game.locationName)"
        mapItem.openInMapsWithLaunchOptions(options)
        
    }

}
