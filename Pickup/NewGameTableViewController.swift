//
//  NewGameTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/17/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import CoreLocation
import Parse


class NewGameTableViewController: UITableViewController, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate, NewGameTableViewDelegate {

    let GAME_TYPE_PICKER = 0
    let NUMBER_OF_PLAYERS_PICKER = 1
    let MAX_PLAYERS = 20
    let MIN_PLAYERS = 5
    let ANNOTATION_ID = "Pin"
    let SEGUE_NEW_GAME_MAP = "showNewGameMap"
    
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnCreate: UIBarButtonItem!
    @IBOutlet weak var lblSport: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPlayers: UILabel!
    @IBOutlet weak var sportPicker: UIPickerView!
    @IBOutlet weak var numberOfPlayersPicker: UIPickerView!
    @IBOutlet weak var btnMap: UIButton!
    @IBOutlet weak var txtGameNotes: UITextView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var txtLocationName: UITextField!
    
    var gameStatus = GameStatus.CREATE
    let editButtonTitle: [GameStatus: String] = [.CREATE: "Create", .EDIT: "Save"]
    
    //For saving to parse
    var selectedGameType: GameType!
    var playersNeeded: Int?
    var gameVenueName: String?
    var gameDate: NSDate?
    var gameLocation: CLLocationCoordinate2D?
    var gameNotes: String? = ""
    
    var gameTypes: [GameType]!
    var address: String? {
        didSet {
            tableView.reloadData()
        }
    }

    var sportRowSelected:Bool = false
    var dateRowSelected:Bool = false
    var playerRowSelected:Bool = false
    var addressLoaded = false
    
    @IBAction func cancelNewGame(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func createNewGame(sender: UIBarButtonItem) {
        
        //validate user input
        //create game object
        let currentUser = PFUser.currentUser()
        
        if enteredDataIsValid() == true {
            let newGame: Game = Game.init(id: "_newGame", gameType: selectedGameType, totalSlots: playersNeeded!, availableSlots: playersNeeded!, eventDate: gameDate!, locationName: gameVenueName!, ownerId: (currentUser?.objectId)!, gameNotes: gameNotes!)
            saveParseGameObject(newGame)
        } else {
            markInvalidFields()
        }
        
    }
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        lblDate.text = DateUtilities.dateString(sender.date, dateFormatString: "\(DateFormatter.MONTH_ABBR_AND_DAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
        
        self.gameDate = sender.date
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtGameNotes.delegate = self
        txtLocationName.delegate = self
        txtLocationName.enabled = false
        txtLocationName.hidden = true
        txtLocationName.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        lblPlayers.text = ""
        
        
        if address != nil {
            lblAddress.text = address
        }

        btnCancel.tintColor = Theme.PRIMARY_LIGHT_COLOR
        btnCreate.tintColor = Theme.ACCENT_COLOR
        
        //Set the initial values
        self.gameDate = NSDate()
        if self.selectedGameType == nil {
            self.selectedGameType = self.gameTypes[0]
        }
        
        //Get rid of extra space up top
        let dummyViewHeight: CGFloat = 40
        let dummyView:UIView = UIView.init(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, dummyViewHeight))
        self.tableView.tableHeaderView = dummyView
        self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0)
        
        //Attempting to get rid of extra cell on bottom, not sure if this is working
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        btnMap.tintColor = Theme.ACCENT_COLOR
        
        self.datePicker.minimumDate = NSDate()
        self.datePicker.maximumDate = NSDate().dateByAddingTimeInterval(2 * 7 * 24 * 60 * 60)
        
        
        
        if selectedGameType != nil {
            lblSport.text = selectedGameType.displayName
            //TODO: Get selected game type from picker
        } else {
            lblSport.text = "Basketball"
            sportPicker.selectRow(0, inComponent: 0, animated: false)
        }
        
        
//        lblPlayers.text = "\(10)"
//        numberOfPlayersPicker.selectRow(10 - MIN_PLAYERS, inComponent: 0, animated: false)
        
        
        //Round to second nearest five minute increment
        self.datePicker.date = earliestSuggestedGameTime()
        lblDate.text = DateUtilities.dateString(self.datePicker.date, dateFormatString: "\(DateFormatter.MONTH_ABBR_AND_DAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
        
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        var numberOfRows: Int = 0
        
        switch(pickerView.tag) {
            case GAME_TYPE_PICKER:
                numberOfRows = gameTypes.count
                break
            case NUMBER_OF_PLAYERS_PICKER:
                numberOfRows = MAX_PLAYERS - MIN_PLAYERS
                break
            default:
                numberOfRows = 0
        }
        
        return numberOfRows
    }

    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var rowContents: String = ""
        
        switch(pickerView.tag) {
            case GAME_TYPE_PICKER:
                
                rowContents = gameTypes[row].displayName
                break
            case NUMBER_OF_PLAYERS_PICKER:
                rowContents = "\(row + MIN_PLAYERS)"
                break
            default:
                rowContents = ""
        }
        
        return rowContents

    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch(pickerView.tag) {
            case GAME_TYPE_PICKER:
                selectedGameType = gameTypes[row]
                lblSport.text = gameTypes[row].displayName
                break
            case NUMBER_OF_PLAYERS_PICKER:
                playersNeeded = row + MIN_PLAYERS
                lblPlayers.text = "\(row + MIN_PLAYERS)"
                break
            default:
                break
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.whiteColor()
        
        if indexPath.section == 0 && indexPath.row == 0 {
            sportRowSelected = !sportRowSelected
            dateRowSelected = false
            playerRowSelected = false
            animateReloadTableView()
        } else if indexPath.section == 0 && indexPath.row == 2 {
            playerRowSelected = !playerRowSelected
            sportRowSelected = false
            dateRowSelected = false
        } else if indexPath.section == 1 && indexPath.row == 0 {
            dateRowSelected = !dateRowSelected
            sportRowSelected = false
            playerRowSelected = false
        } else if indexPath.section == 1 && indexPath.row == 2 {
            performSegueWithIdentifier(SEGUE_NEW_GAME_MAP, sender: self)
            sportRowSelected = false
            dateRowSelected = false
            playerRowSelected = false
        } else {
            sportRowSelected = false
            dateRowSelected = false
            playerRowSelected = false
        }
        
        animateReloadTableView()
    }
    
    override func tableView(tableView : UITableView,  titleForHeaderInSection section: Int) -> String {
        return " "
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        var rowHeight:CGFloat = 44
        
        if indexPath.section == 0 && indexPath.row == 1 {
            if sportRowSelected == false {
                rowHeight = 0.0
            } else {
                rowHeight = 130.0
            }
        }
        
        if indexPath.section == 0 && indexPath.row == 3 {
            if playerRowSelected == false {
                rowHeight = 0.0
            } else {
                rowHeight = 130.0
            }
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            if dateRowSelected == false {
                datePicker.hidden = true
                rowHeight = 0.0
            } else {
                datePicker.hidden = false
                rowHeight = 220.0
            }
        }
        
        if indexPath.section == 1 && indexPath.row == 2 {
            if address != nil {
                rowHeight = 115
            }
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            rowHeight = 170.0
        }
        

        
        return rowHeight
    }
    
    
    private func animateReloadTableView() -> Void {
        UIView.transitionWithView(tableView,
            duration:0.35,
            options: [.AllowAnimatedContent, .TransitionCrossDissolve],
            animations:
            { () -> Void in
                self.tableView.reloadData()
            },
            completion: nil);
    }
    
    func animateCellValidation(cell: UITableViewCell) -> Void {
        
        cell.backgroundColor = Theme.ERROR_FLASH_COLOR
        
        UIView.animateWithDuration(0.5) { () -> Void in
            cell.backgroundColor = Theme.ERROR_COLOR
        }
        
    }
    
    
    //MARK: - Text Field Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.selectAll(self)
    }
    
    func textFieldDidChange(textField: UITextField) {
        self.gameVenueName = textField.text
    }
    

    
    
    //MARK: - Text View Delegate
    
    func textViewDidEndEditing(textView: UITextView) {
        self.gameNotes = textView.text
    }
    
    func textViewDidChange(textView: UITextView) {
        self.gameNotes = textView.text
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Add notes..." {
            textView.text = ""
        }
    }
    
    func textViewShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    
    //MARK: - New Game Table View Delegate

    func setGameLocationCoordinate(coordinate: CLLocationCoordinate2D) {
        self.gameLocation = coordinate
    }
    
    func setGameLocationName(locationName: String) {
        
        txtLocationName.hidden = false
        txtLocationName.enabled = true
        txtLocationName.text = ""
        self.gameVenueName = locationName
        txtLocationName.text = locationName
        txtLocationName.becomeFirstResponder()
    }
    
    func setLocationTitle() {
        txtLocationName.text = self.gameVenueName
    }
    
    func setGameAddress(address: String) {
        self.address = address
        lblAddress.text = address
    }
    
    //MARK: - User Input Validation
    private func enteredDataIsValid() -> Bool {
        
        var isValid = true
        
        if self.selectedGameType == nil {
            isValid = false
        }
        
        if self.playersNeeded == nil {
            isValid = false
        }
        
        if self.gameVenueName == nil {
            isValid = false
        }
        
        if self.gameDate == nil {
            isValid = false
        }
        
        if self.gameLocation == nil {
            isValid = false
        }
        
        return isValid
    }
    
    private func markInvalidFields() {
        
        if self.selectedGameType == nil {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.backgroundColor = Theme.ERROR_COLOR
        }
        
        if self.playersNeeded == nil {
            let indexPath = NSIndexPath(forRow: 2, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                animateCellValidation(cell)
            }
        }
        
        if self.gameLocation == nil {
            let indexPath = NSIndexPath(forRow: 2, inSection: 1)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                animateCellValidation(cell)
            }

        }
        
        if self.gameVenueName == "" {
            if txtLocationName.hidden == false {
                let indexPath = NSIndexPath(forRow: 2, inSection: 1)
                if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                    animateCellValidation(cell)
                }
                txtLocationName.becomeFirstResponder()
            }
        }
        
    }
    
    
    //MARK: - Parse
    
    private func saveParseGameObject(game: Game) {
        
        let gameObject = PFObject(className: "Game")
        
        gameObject["gameType"] = PFObject(withoutDataWithClassName: "GameType", objectId: selectedGameType.id)
        gameObject["date"] = self.gameDate
        let point = PFGeoPoint(latitude:self.gameLocation!.latitude, longitude: self.gameLocation!.longitude)
        gameObject["location"] = point
        gameObject["locationName"] = self.gameVenueName
        gameObject["gameNotes"] = self.gameNotes
        gameObject["owner"] = PFUser.currentUser()
        gameObject.relationForKey("players").addObject(PFUser.currentUser()!)
        gameObject["totalSlots"] = self.playersNeeded! + 1
        gameObject["slotsAvailable"] = self.playersNeeded!
        gameObject["isCancelled"] = false
        
        gameObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                let gameId = gameObject.objectId! as String
                self.addGameToUserDefaults(gameId)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                //TODO: Add some sort of alert to say that the game could not be saved
            }
        }
    }
    
    //MARK: - User Defaults
    
    private func addGameToUserDefaults(gameId: String) {
        
        if let joinedGames = NSUserDefaults.standardUserDefaults().objectForKey("userJoinedGamesById") as? NSArray {
            let gameIdArray = joinedGames.mutableCopy()
            gameIdArray.addObject(gameId)
            NSUserDefaults.standardUserDefaults().setObject(gameIdArray, forKey: "userJoinedGamesById")
        } else {
            var gameIdArray: [String] = []
            gameIdArray.append(gameId)
            NSUserDefaults.standardUserDefaults().setObject(gameIdArray, forKey: "userJoinedGamesById")
        }
        
    }
    
    //MARK: - Date Time
    
    func earliestSuggestedGameTime() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let date = NSDate()
        let minuteComponent = calendar.components([.Minute], fromDate: date)
        let remainder = minuteComponent.minute % 10
        let minutesToAdd: Int
        if remainder < 5 {
            minutesToAdd = 10 - remainder
        } else {
            minutesToAdd = 15 - remainder
        }
        
        let components = NSDateComponents()
        components.minute = minutesToAdd
        return calendar.dateByAddingComponents(components, toDate: date, options: .MatchFirst)!
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_NEW_GAME_MAP {
            
            let newGameMapViewController = segue.destinationViewController as? NewGameMapViewController
            
            newGameMapViewController?.newGameTableViewDelegate = self
            
            if self.gameVenueName != nil && self.gameLocation != nil {
                newGameMapViewController?.locationName = self.gameVenueName!
                newGameMapViewController?.gameLocation = self.gameLocation!
            }
            
        }
    }
    


}
