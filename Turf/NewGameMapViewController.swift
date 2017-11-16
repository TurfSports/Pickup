//
//  NewGameMapViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/25/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NewGameMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIBarPositioningDelegate, UISearchBarDelegate, UITableViewDelegate {

    let ANNOTATION_ID = "Pin"
    let SEGUE_NEW_GAME = "showNewGameTableViewController"
    
    var newGameTableViewDelegate: NewGameTableViewDelegate?
    
    var selectedPin:MKPlacemark? = nil
    var matchingItems:[MKMapItem] = []
    
    var address = ""
    var locationName = ""
    var gameLocation: CLLocationCoordinate2D?
    var hasLoadedLocationsBefore: Bool = false
    
    var locationStatus: LocationStatus = .location_NOT_SET
    let rightNavBarButtonTitle: [LocationStatus: String] = [.location_NOT_SET: "Set Location", .location_SET: "Change Location"]
    
    @IBOutlet weak var newGameMap: MKMapView!
    @IBOutlet weak var btnSaveLocation: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var lblTapTip: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewSearchResults: UITableView!
    
    var currentLocation:CLLocation?

    @IBAction func cancelModal(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveLocation(_ sender: UIBarButtonItem) {
        
        if address == "" {
            //TODO: Make an alert that no location was selected
        } else {
            newGameTableViewDelegate?.setGameLocationCoordinate(self.gameLocation!)
            newGameTableViewDelegate?.setGameAddress(self.address)
            newGameTableViewDelegate?.setGameLocationName(self.locationName)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OverallLocation.manager.delegate = self
        
        tableViewSearchResults.isHidden = true
         tableViewSearchResults.tableFooterView = UIView(frame: CGRect.zero)
        
        btnCancel.tintColor = Theme.PRIMARY_LIGHT_COLOR
        btnSaveLocation.tintColor = Theme.ACCENT_COLOR
        
        setUsersCurrentLocation()
        setUpMapScreen()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        OverallLocation.manager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        OverallLocation.manager.stopUpdatingLocation()
    }
    
    fileprivate func setUpMapScreen() {
        
        btnSaveLocation.title = rightNavBarButtonTitle[locationStatus]!
        if locationStatus == .location_SET {
            //TODO: Drop Current Game Location and change button to change location
            //dropGameAnnotation
        } else {
            setGestureRecognizer()
        }
        
    }

    //MARK: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            OverallLocation.manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if Settings.shared.defaultLocation == "none" {
            if let location = locations.first, self.hasLoadedLocationsBefore == false {
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                newGameMap.setRegion(region, animated: false)
                hasLoadedLocationsBefore = true
            }
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    func setUsersCurrentLocation() {
        OverallLocation.manager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            OverallLocation.manager.delegate = self
            OverallLocation.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            //OverallLocation.manager.requestLocation()
        }
    }
    
    
    func computeViewSettings(_ latitude: Double, longitude: Double) {
        
        var latDelta:CLLocationDegrees = 0.02
        var longDelta:CLLocationDegrees = 0.02
        
        if Settings.shared.defaultLocation != "none" {
            latDelta = 0.2
            longDelta = 0.2
        }
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        newGameMap.setRegion(region, animated: false)
        
    }
    
    
    //MARK: - Map View Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: ANNOTATION_ID) as? MKPinAnnotationView
        
        if pinView == nil && !annotation.isKind(of: MKUserLocation.self) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOTATION_ID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.image = UIImage(named: "annotationIcon")
        }
        
        //TODO: - Consider adding a custom color
        //http://stackoverflow.com/questions/2370567/custon-mkpinannotationcolor
        
        return pinView
        
    }
    
    //MARK: - Search Bar Delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableViewSearchResults.isHidden = false
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tableViewSearchResults.isHidden = true
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableViewSearchResults.isHidden = true
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request = MKLocalSearchRequest()
        guard let text = searchBar.text, searchBar.text != "" else { return }
        request.naturalLanguageQuery = text
        request.region = newGameMap.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response, error == nil else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableViewSearchResults.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//
//        let request = MKLocalSearchRequest()
//        request.naturalLanguageQuery = searchText
//        request.region = newGameMap.region
//        let search = MKLocalSearch(request: request)
//        search.start { response, _ in
//            guard let response = response else {
//                return
//            }
//            self.matchingItems = response.mapItems
//            self.tableViewSearchResults.reloadData()
//        }
    }
    
    //MARK: - Table View Delegate
    @objc func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    @objc func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
        
        lblTapTip.isHidden = true
        removePreviousAnnotation()
        setAnnotation(selectedItem.coordinate)
        
        self.gameLocation = selectedItem.coordinate
        buildAddressString(selectedItem.coordinate)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(selectedItem.coordinate, span)
        newGameMap.setRegion(region, animated: false)
        
        tableViewSearchResults.isHidden = true
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    //MARK: - Gesture recognizer
    func setGestureRecognizer() {
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dropPinOnLocation:")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewGameMapViewController.dropPinOnLocation(_:)))
        newGameMap.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func dropPinOnLocation(_ gestureRecognizer: UIGestureRecognizer) {
        
        let touchPoint = gestureRecognizer.location(in: self.newGameMap)
        let coordinate: CLLocationCoordinate2D = newGameMap.convert(touchPoint, toCoordinateFrom: self.newGameMap)
        
        lblTapTip.isHidden = true
        removePreviousAnnotation()
        setAnnotation(coordinate)
        
        self.gameLocation = coordinate
        buildAddressString(coordinate)
    }
    
    func setAnnotation(_ coordinate: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        self.newGameMap.addAnnotation(annotation)
        
    }
    
    func removePreviousAnnotation() {
        let annotations = self.newGameMap.annotations
        self.newGameMap.removeAnnotations(annotations)
    }
    
    func parseAddress(_ selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    func buildAddressString(_ coordinate: CLLocationCoordinate2D) {
        
        let geoCoder = CLGeocoder()
        let gameLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(gameLocation, completionHandler: { (placemarks, error) -> Void in
            
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            self.address = ""
            
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                self.address = self.address + "\(locationName)"
                self.locationName = locationName as String
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
    
    //MARK: - Bar Positioning Delegate
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    

}
