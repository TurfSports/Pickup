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
    
    @IBAction func addToCalendar(_ sender: UIButton) {
        _ = insertGameIntoCalendar()
        UIApplication.shared.openURL(URL(string: "calshow:\(game.eventDate.timeIntervalSinceReferenceDate)")!)
    }
    
    @IBAction func openInMaps(_ sender: UIButton) {
        openMapsForPlace()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAddToCalendar.isHidden = true

        btnOpenMaps.tintColor = Theme.ACCENT_COLOR
        btnAddToCalendar.tintColor = Theme.ACCENT_COLOR
        
        self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
        if game.userJoined == true {
            btnAddToCalendar.isHidden = false
        }
        
        lblGameNotes.text = game.gameNotes
        if game.gameNotes == "" {
            lblGameNotes.text = "No notes for this game"
        }
        
        lblGameNotes.sizeToFit()
        
        lblDay.text = DateUtilities.dateString(game.eventDate, dateFormat: DateFormatter.MONTH_DAY_YEAR.rawValue)
        lblTime.text = DateUtilities.dateString(game.eventDate, dateFormat: DateFormatter.TWELVE_HOUR_TIME.rawValue)
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        var height = UITableViewAutomaticDimension
        
        if (indexPath as NSIndexPath).section == 3 && (indexPath as NSIndexPath).row == 0 {
            if isOwner == false {
                height = 0.0
            } else {
                height = 44.0
            }
        }
        

        return height
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension

    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height:CGFloat = 5.0
        if section == 0 {
            height = 0
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 3 && (indexPath as NSIndexPath).row == 0 {
            parentDelegate.cancelGame(self.game)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.isUserInteractionEnabled = false
        cell?.selectionStyle = .none
        
        if (indexPath as NSIndexPath).section == 3 && (indexPath as NSIndexPath).row == 0 {
            cell?.isUserInteractionEnabled = true
            cell?.selectionStyle = .gray
        }
        
        return indexPath
        
    }
    
    func insertGameIntoCalendar () -> String {
        
        var resultString = ""
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            insertEvent(eventStore)
            resultString = "Access granted to event store"
        case .denied:
            resultString = "Access denied to event store"
        case .notDetermined:
            return resultString
//            eventStore.requestAccess(to: .event, completion:
//                ({[weak self] (granted: Bool, error: NSError?) -> Void in
//                    if granted {
//                        self!.insertEvent(eventStore)
//                    } else {
//                        resultString = "Access denied to event store"
//                    }
//                    } as? EKEventStoreRequestAccessCompletionHandler)!)
        default:
            resultString = "Default"
        }
        
        print (resultString)
        return resultString
        
    }
    
    
    func insertEvent(_ store: EKEventStore) {

        let calendars = store.calendars(for: .event)

        let event = EKEvent(eventStore: store)
        
        for calendar in calendars {
            if calendar.allowsContentModifications {
                print(calendar.title)
                event.calendar = calendar
                event.title = "\(game.gameType.displayName) at \(game.locationName)"
                event.startDate = game.eventDate as Date
                event.endDate = game.eventDate.addingTimeInterval(1.5 * 60 * 60) as Date
                
                do {
                    try store.save(event, span: .thisEvent)
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
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(game.locationName)"
        mapItem.openInMaps(launchOptions: options)
        
    }

}
