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
    let MAX_PLAYERS = 30
    let MIN_PLAYERS = 1
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
    
    //If editing a game, this will be passed through the segue
    //else it will be initialized in this view controller
    var game: Game!
    var gameObject: PFObject!
    
    var selectedGameType: GameType!
    
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
        
        if enteredDataIsValid() == true {
            saveParseGameObject(self.game)
        } else {
            markInvalidFields()
        }
    }
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        lblDate.text = DateUtilities.dateString(sender.date, dateFormatString: "\(DateFormatter.MONTH_ABBR_AND_DAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
        
        self.game.eventDate = sender.date
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtGameNotes.delegate = self
        txtLocationName.delegate = self
        txtLocationName.enabled = false
        txtLocationName.hidden = true
        txtLocationName.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        
        if gameStatus == .EDIT && self.game != nil {
            getGameObjectFromParse()
            setStoredValues()
        } else if gameStatus == .CREATE {
            createDefaultGame()
            setDefaultInitialValues()
        }
        
        btnCancel.tintColor = Theme.PRIMARY_LIGHT_COLOR
        btnCreate.tintColor = Theme.ACCENT_COLOR
        btnMap.tintColor = Theme.ACCENT_COLOR
        removeTopWhiteSpace()

        self.datePicker.minimumDate = NSDate()
        self.datePicker.maximumDate = NSDate().dateByAddingTimeInterval(2 * 7 * 24 * 60 * 60)
        self.numberOfPlayersPicker.selectRow(9, inComponent: 0, animated: false)
        
        
        //Attempting to get rid of extra cell on bottom, not sure if this is working
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    private func getGameObjectFromParse() {
        
        let gameQuery = PFQuery(className:"GameScore")
        gameQuery.getObjectInBackgroundWithId("xWMyZEGZ") {
            (gameObject: PFObject?, error: NSError?) -> Void in
            if error == nil && gameObject != nil {
                self.gameObject = gameObject
            } else {
                self.gameObject = nil
            }
        }
    }
    
    private func setStoredValues() {
        
        lblSport.text = self.game.gameType.displayName
        sportPicker.selectRow(self.game.gameType.sortOrder, inComponent: 0, animated: false)
        
        lblPlayers.text = "\(self.game.totalSlots - 1)"
        numberOfPlayersPicker.selectRow(self.game.totalSlots - 1, inComponent: 0, animated: false)
        
        datePicker.date = self.game.eventDate
        lblDate.text = DateUtilities.dateString(self.datePicker.date, dateFormatString: "\(DateFormatter.MONTH_ABBR_AND_DAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
        
        txtLocationName.text = self.game.locationName
        
        if address != nil {
            lblAddress.text = address
        }
        
        txtGameNotes.text = self.game.gameNotes
    }
    
    private func createDefaultGame() {
        
        let defaultGameType: GameType
        if self.selectedGameType == nil {
            defaultGameType = self.gameTypes[0]
        } else {
            defaultGameType = self.selectedGameType
        }
        
        let currentUser = PFUser.currentUser()
        self.game = Game.init(id: "_newGame", gameType: defaultGameType, totalSlots: 0, availableSlots: 0, eventDate: NSDate(), locationName: "", ownerId: (currentUser?.objectId)!, gameNotes: "")
    }
    
    private func setDefaultInitialValues() {
        
        lblPlayers.text = ""
        
        lblSport.text = self.game.gameType.displayName
        sportPicker.selectRow(self.game.gameType.sortOrder - 1, inComponent: 0, animated: false)
        
        //Round to second nearest five minute increment
        self.datePicker.date = earliestSuggestedGameTime()
        lblDate.text = DateUtilities.dateString(self.datePicker.date, dateFormatString: "\(DateFormatter.MONTH_ABBR_AND_DAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
    }
    

    
    
    func removeTopWhiteSpace() {
        let dummyViewHeight: CGFloat = 40
        let dummyView:UIView = UIView.init(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, dummyViewHeight))
        self.tableView.tableHeaderView = dummyView
        self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0)
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
                self.game.gameType = gameTypes[row]
                lblSport.text = gameTypes[row].displayName
                break
            case NUMBER_OF_PLAYERS_PICKER:
                self.game.totalSlots = row + MIN_PLAYERS
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
            if lblPlayers.text == "" || lblPlayers.text == nil {
                lblPlayers.text = "\(numberOfPlayersPicker.selectedRowInComponent(0) + 1)"
                self.game.totalSlots = numberOfPlayersPicker.selectedRowInComponent(0) + 1
            }
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
        self.game.locationName = textField.text!
        if self.game.locationName != "" {
            let indexPath = NSIndexPath(forRow: 2, inSection: 1)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.backgroundColor = UIColor.whiteColor()
        } else {
            let indexPath = NSIndexPath(forRow: 2, inSection: 1)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.backgroundColor = Theme.ERROR_COLOR
        }
    }
    
    
    //MARK: - Text View Delegate
    
    func textViewDidEndEditing(textView: UITextView) {
        self.game.gameNotes = textView.text
    }
    
    func textViewDidChange(textView: UITextView) {
        self.game.gameNotes = textView.text
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
        self.game.latitude = coordinate.latitude
        self.game.longitude = coordinate.longitude
    }
    
    func setGameLocationName(locationName: String) {
        
        txtLocationName.hidden = false
        txtLocationName.enabled = true
        txtLocationName.text = ""
        self.game.locationName = locationName
        txtLocationName.text = locationName
        txtLocationName.becomeFirstResponder()
    }
    
    func setLocationTitle() {
        txtLocationName.text = self.game.locationName
    }
    
    func setGameAddress(address: String) {
        self.address = address
        lblAddress.text = address
    }
    
    //MARK: - User Input Validation
    private func enteredDataIsValid() -> Bool {
        
        var isValid = true
        
        if self.game.totalSlots == 0 {
            isValid = false
        }
        
        if self.game.locationName == "" {
            isValid = false
        }
        
        if self.game.latitude == 0.0 {
            isValid = false
        }
        
        return isValid
    }
    
    private func markInvalidFields() {
        
        if self.game.totalSlots == 0 {
            let indexPath = NSIndexPath(forRow: 2, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                animateCellValidation(cell)
            }
        }
        
        if self.game.latitude == 0.0 {
            let indexPath = NSIndexPath(forRow: 2, inSection: 1)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                animateCellValidation(cell)
            }

        }
        
        if self.game.locationName == "" {
            let indexPath = NSIndexPath(forRow: 2, inSection: 1)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                animateCellValidation(cell)
            }
            txtLocationName.becomeFirstResponder()
        }
        
    }
    
    
    //MARK: - Parse
    
    private func saveParseGameObject(game: Game) {
        
        var gameObject: PFObject
        
        if gameStatus == .CREATE {
            gameObject = PFObject(className: "Game")
        } else { //gameStatus == .EDIT
            gameObject = self.gameObject
        }
        
        setGameObjectFields(gameObject)
        saveGameObjectInBackground(gameObject)

    }
    
    
    private func setGameObjectFields(gameObject: PFObject) {
        
        gameObject["gameType"] = PFObject(withoutDataWithClassName: "GameType", objectId: self.game.gameType.id)
        gameObject["date"] = self.game.eventDate
        let point = PFGeoPoint(latitude:self.game.latitude, longitude: self.game.longitude)
        gameObject["location"] = point
        gameObject["locationName"] = self.game.locationName
        gameObject["gameNotes"] = self.game.gameNotes
        gameObject["owner"] = PFUser.currentUser()
        gameObject.relationForKey("players").addObject(PFUser.currentUser()!)
        gameObject["totalSlots"] = self.game.totalSlots + 1
        gameObject["slotsAvailable"] = self.game.totalSlots
        gameObject["isCancelled"] = false
        
    }
    
    private func saveGameObjectInBackground (gameObject: PFObject) {
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
            
            if self.game.locationName != "" && self.game.latitude != 0.0 {
                newGameMapViewController?.locationName = self.game.locationName
                newGameMapViewController?.gameLocation = CLLocationCoordinate2DMake(self.game.latitude, self.game.longitude)
            }
            
        }
    }
    


}
