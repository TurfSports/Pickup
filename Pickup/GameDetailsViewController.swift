//
//  GameDetailsViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/1/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import Parse
import MapKit

class GameDetailsViewController: UIViewController, MKMapViewDelegate {

    

    @IBOutlet weak var lblLocationName: UILabel!
    @IBOutlet weak var lblOpenings: UILabel!
    @IBOutlet weak var mapGame: MKMapView!
    @IBOutlet weak var lblGameNotes: UILabel!
    @IBOutlet weak var imgGameType: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblHour: UILabel!
    @IBOutlet weak var btnJoinGame: UIBarButtonItem!
    @IBOutlet weak var btnOpenMaps: UIBarButtonItem!
    @IBOutlet weak var btnAddToCalendar: UIButton!
    
    
    var address: String! {
        didSet {
            lblAddress.text = address
        }
    }
    
    var game: Game!
    let ANNOTATION_ID = "Pin"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnJoinGame.tintColor = Theme.PRIMARY_DARK_COLOR
        btnOpenMaps.tintColor = Theme.PRIMARY_DARK_COLOR
        btnAddToCalendar.tintColor = Theme.PRIMARY_DARK_COLOR
    
        lblLocationName.text = game.locationName
        lblOpenings.text = ("\(game.availableSlots) openings")
        lblGameNotes.text = game.gameNotes
        lblDay.text = DateUtilities.dateString(game.eventDate, dateFormatString: DateFormatter.MONTH_ABBR_AND_DAY.rawValue)
        lblHour.text = DateUtilities.dateString(game.eventDate, dateFormatString: DateFormatter.TWELVE_HOUR_TIME.rawValue)
        lblAddress.text = ""
        
        let location = setLocationOnMap(game.latitude, longitude: game.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = game.locationName
        mapGame.addAnnotation(annotation)
        
        
        imgGameType.image = UIImage(named: game.gameType.imageName)
        imgGameType.layer.cornerRadius = 47
        imgGameType.layer.masksToBounds = true
        
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
            
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                self.address = self.address + "\n\(street)"

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
    
    
    
    @IBAction func btnJoinGame(sender: AnyObject) {
        
        //Get the PFObject for game
        //Add the current user as a player in the game
        let alertController = UIAlertController(title: "Join Game", message:
            "Are you sure you want to join this game?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
        alertController.addAction(UIAlertAction(title: "Join", style: UIAlertActionStyle.Default, handler: { action in
            switch action.style {
            case .Default:
                print("default")
                
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    
        
        joinPFUserToPFGame()
        
    }
    
    //MARK: - Load game from parse
    private func joinPFUserToPFGame() {
        let gameQuery = PFQuery(className: "Game")
        gameQuery.whereKey("objectId", equalTo: self.game.id)
        
        gameQuery.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                print("The getFirstObject on Game request failed.")
            } else {
                let currentUser = PFUser.currentUser()
                let gameRelations = object?.relationForKey("players")
                gameRelations?.addObject(currentUser!)
                object?.saveInBackground()
            }
        }
    
    }

    
    // MARK: - Map view delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOTATION_ID)
        view.canShowCallout = true
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // NEEDSWORK: begin editing suggestion for this geoplace
    }
    
    // MARK: - Private functions
    
    private func setLocationOnMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> CLLocationCoordinate2D {
        
        let latDelta:CLLocationDegrees = 0.01
        let longDelta:CLLocationDegrees = 0.01
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapGame.setRegion(region, animated: false)
        
        return location
    }
    

}
