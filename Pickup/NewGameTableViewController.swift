//
//  NewGameTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/17/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import Parse


var emptyGameType: GameType = GameType.init(id: "", name: "", displayName: "", sortOrder: 1, imageName: "")

var emptyGame: Game = Game.init(id: "", gameType: emptyGameType, totalSlots: 1, availableSlots: 1, eventDate: Date.init(), locationName: "", ownerId: "", gameNotes: "")


class NewGameTableViewController: UITableViewController, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate, NewGameTableViewDelegate, Dismissable {

    let GAME_TYPE_PICKER = 0
    let NUMBER_OF_PLAYERS_PICKER = 1
    let MAX_PLAYERS = 30
    var MIN_PLAYERS = 1
    let ANNOTATION_ID = "Pin"
    let SEGUE_NEW_GAME_MAP = "showNewGameMap"

    var gameDetailsDelegate: GameDetailsViewDelegate!
    var dismissalDelegate: DismissalDelegate?
    
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
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var sportTableViewCell: UITableViewCell!

    var editingNotes = false
    var gameStatus = GameStatus.create
    let editButtonTitle: [GameStatus: String] = [.create: "Create", .edit: "Save"]
    let navBarTitle: [GameStatus: String] = [.create: "New Game", .edit: "Edit Game"]
    
    //If editing a game, this will be passed through the segue
    //else it will be initialized in  this view controller

    var game: Game = emptyGame
    
    var gameObject: PFObject!
    
    var selectedGameType: GameType!
    
    var gameTypes: [GameType] = []
    var address: String? {
        didSet {
            tableView.reloadData()
        }
    }
    
    //This is somewhat of a hack
    var gameNotesTableViewHeight: CGFloat!

    var sportRowSelected:Bool = false
    var dateRowSelected:Bool = false
    var playerRowSelected:Bool = false
    var addressLoaded = false
    
    @IBAction func cancelNewGame(_ sender: UIBarButtonItem) {
        
        if editingNotes == false {
            self.dismiss(animated: true, completion: nil)
        } else {
            txtGameNotes.resignFirstResponder()
        }
    }
    
    @IBAction func createNewGame(_ sender: UIBarButtonItem) {
        
        if editingNotes == false  {
            if enteredDataIsValid() == true {
                FIr.
                
                if !NotificationsManager.notificationsInitiated() {
                    NotificationsManager.registerNotifications()
                }
                
            } else {
                markInvalidFields()
            }
        } else {
            self.game.gameNotes = txtGameNotes.text
            self.txtGameNotes.resignFirstResponder()
            
            if gameStatus == .create {
                btnCreate.title = "Create"
            } else {
                btnCreate.title = "Save"
            }
            
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        lblDate.text = DateUtilities.dateString(sender.date, dateFormatString: "\(DateFormatter.MONTH_ABBR_AND_DAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
        
        if self.gameObject != nil {
            self.gameObject["eventDate"] = sender.date
        }
        
        self.game.eventDate = sender.date
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            
        self.setHeightForGameNotesTableCell()
        
        self.txtGameNotes.delegate = self
        self.txtLocationName.delegate = self
//        txtLocationName.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.txtLocationName.addTarget(self, action: #selector(NewGameTableViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        self.MIN_PLAYERS = 1
        
        self.btnCreate.title = self.editButtonTitle[self.gameStatus]!
        self.navigationItem.title = self.navBarTitle[self.gameStatus]!
        
        if self.gameStatus == .edit {
            self.getGameObjectFromParse()
            self.sportTableViewCell.isUserInteractionEnabled = false
            self.sportTableViewCell.selectionStyle = .none
            self.sportTableViewCell.backgroundColor = Theme.UNEDITABLE_CELL_COLOR
            self.txtLocationName.isEnabled = true
            self.txtLocationName.isHidden = false
            self.setStoredValues()
        } else if self.gameStatus == .create {
            self.createDefaultGame()
            self.txtLocationName.isEnabled = false
            self.txtLocationName.isHidden = true
            self.setDefaultInitialValues()
        }
            
        self.MIN_PLAYERS = self.game.totalSlots - self.game.availableSlots - 1
        if self.MIN_PLAYERS < 1 {
            self.MIN_PLAYERS = 1
        }

        self.btnCancel.tintColor = Theme.PRIMARY_LIGHT_COLOR
        self.btnCreate.tintColor = Theme.ACCENT_COLOR
        self.btnMap.tintColor = Theme.ACCENT_COLOR
        self.removeTopWhiteSpace()

        self.datePicker.minimumDate = Date()
        self.datePicker.maximumDate = Date().addingTimeInterval(2 * 7 * 24 * 60 * 60)
        
        
        //Attempting to get rid of extra cell on bottom, not sure if this is working
        self.tableView.tableFooterView = self.footerView
        }
    }
    
    func setHeightForGameNotesTableCell() {
        let heightAboveGameNotes: CGFloat = 322.0
        self.gameNotesTableViewHeight = self.tableView.bounds.height - heightAboveGameNotes
    }
    

    
    fileprivate func setStoredValues() {
        
        lblSport.text = self.game.gameType.displayName
        sportPicker.selectRow(self.game.gameType.sortOrder, inComponent: 0, animated: false)
        
        lblPlayers.text = "\(self.game.totalSlots - 1)"
        numberOfPlayersPicker.selectRow(self.game.availableSlots, inComponent: 0, animated: false)
        
        datePicker.date = self.game.eventDate as Date
        lblDate.text = DateUtilities.dateString(self.datePicker.date, dateFormatString: "\(DateFormatter.MONTH_ABBR_AND_DAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
        
        txtLocationName.text = self.game.locationName
        
        if address != nil {
            lblAddress.text = address
        }
        
        txtGameNotes.text = self.game.gameNotes
    }
    
    fileprivate func createDefaultGame() {
        
        DispatchQueue.main.async {
        
        let defaultGameType: GameType
        if self.selectedGameType == nil {
            defaultGameType = emptyGameType
        } else {
            defaultGameType = self.selectedGameType
        }
        
        self.numberOfPlayersPicker.selectRow(9, inComponent: 0, animated: false)
        
        var currentUser = PFUser.current()
        if currentUser == nil { currentUser = PFUser.init() }
        self.game = Game.init(id: "_newGame", gameType: defaultGameType, totalSlots: 0, availableSlots: 0, eventDate: self.earliestSuggestedGameTime(), locationName: "", ownerId: (currentUser?.objectId) ?? "_userID", gameNotes: "")
        
        self.game.userIsOwner = true
        self.game.userJoined = true
        self.game.ownerId = (currentUser?.objectId) ?? "_userID"
        }
    }
    
    fileprivate func setDefaultInitialValues() {
        
        DispatchQueue.main.async {
        
        self.lblPlayers.text = ""
        
        self.lblSport.text = self.game.gameType.displayName
        self.sportPicker.selectRow(self.game.gameType.sortOrder - 1, inComponent: 0, animated: false)
        
        //Round to second nearest five minute increment
        self.datePicker.date = self.earliestSuggestedGameTime()
        self.lblDate.text = DateUtilities.dateString(self.datePicker.date, dateFormatString: "\(DateFormatter.MONTH_ABBR_AND_DAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
        }
    }
    
    func removeTopWhiteSpace() {
        let dummyViewHeight: CGFloat = 40
        let dummyView:UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.tableHeaderView = dummyView
        self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0)
    }
    
    
    //MARK: - Picker view delegate
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
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

    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch(pickerView.tag) {
            case GAME_TYPE_PICKER:
                self.game.gameType = gameTypes[row]
                lblSport.text = gameTypes[row].displayName
                break
            case NUMBER_OF_PLAYERS_PICKER:
                
                if self.gameObject != nil {
                    self.gameObject["totalSlots"] = row + MIN_PLAYERS + 1
                    self.gameObject["availableSlots"] = row + MIN_PLAYERS
                }
                
                self.game.totalSlots = row + MIN_PLAYERS + 1
                self.game.availableSlots = row + MIN_PLAYERS
                
                lblPlayers.text = "\(row + MIN_PLAYERS)"
                break
            default:
                break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.white
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 && gameStatus == .create {
            sportRowSelected = !sportRowSelected
            dateRowSelected = false
            playerRowSelected = false
            animateReloadTableView()
        } else if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 2 {
            playerRowSelected = !playerRowSelected
            if lblPlayers.text == "" || lblPlayers.text == nil {
                lblPlayers.text = "\(numberOfPlayersPicker.selectedRow(inComponent: 0) + 1)"
                self.game.totalSlots = numberOfPlayersPicker.selectedRow(inComponent: 0) + 1
                self.game.availableSlots = numberOfPlayersPicker.selectedRow(inComponent: 0)
            }
            sportRowSelected = false
            dateRowSelected = false
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            dateRowSelected = !dateRowSelected
            sportRowSelected = false
            playerRowSelected = false
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 2 {
            performSegue(withIdentifier: SEGUE_NEW_GAME_MAP, sender: self)
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
    
    override func tableView(_ tableView : UITableView,  titleForHeaderInSection section: Int) -> String {
        return " "
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        var rowHeight:CGFloat = 44.0
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 1 {
            if sportRowSelected == false {
                rowHeight = 0.0
            } else {
                rowHeight = 130.0
            }
        }
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 3 {
            if playerRowSelected == false {
                rowHeight = 0.0
            } else {
                rowHeight = 130.0
            }
        }
        
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 {
            if dateRowSelected == false {
                datePicker.isHidden = true
                rowHeight = 0.0
            } else {
                datePicker.isHidden = false
                rowHeight = 220.0
            }
        }
        
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 2 {
            if address != nil {
                rowHeight = 115
            }
        }
        
        if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0 {
            DispatchQueue.main.async {
                rowHeight = self.gameNotesTableViewHeight
            }
        }
        
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 && self.gameStatus == .edit {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isUserInteractionEnabled = false
            cell?.selectionStyle = .none
            lblSport.tintColor = UIColor.black
        }
        
        return indexPath
    }
    
    
    //MARK: - Animation
    
    fileprivate func animateReloadTableView() -> Void {
        UIView.transition(with: tableView,
            duration:0.35,
            options: [.allowAnimatedContent, .transitionCrossDissolve],
            animations:
            { () -> Void in
                self.tableView.reloadData()
            },
            completion: nil);
    }
    
    func animateCellValidation(_ cell: UITableViewCell) -> Void {
        
        cell.backgroundColor = Theme.ERROR_FLASH_COLOR
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            cell.backgroundColor = Theme.ERROR_COLOR
        }) 
        
    }
    
    
    //MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(self)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        self.game.locationName = textField.text!
        if self.game.locationName != "" {
            let indexPath = IndexPath(row: 2, section: 1)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.backgroundColor = UIColor.white
        } else {
            let indexPath = IndexPath(row: 2, section: 1)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.backgroundColor = Theme.ERROR_COLOR
        }
    }
    
    
    //MARK: - Text View Delegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.game.gameNotes = textView.text
        if self.gameStatus == GameStatus.create {
            self.btnCreate.title = "Create"
        } else {
            self.btnCreate.title = "Save"
        }
        
        self.editingNotes = false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add notes..." {
            textView.text = ""
        }
        
        self.editingNotes = true
        self.btnCreate.title = "Done"
    }
    
    
    //MARK: - New Game Table View Delegate

    func setGameLocationCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.game.latitude = coordinate.latitude
        self.game.longitude = coordinate.longitude
    }
    
    func setGameLocationName(_ locationName: String) {
        
        txtLocationName.isHidden = false
        txtLocationName.isEnabled = true
        self.game.locationName = locationName
        txtLocationName.text = locationName
        txtLocationName.becomeFirstResponder()
    }
    
    func setLocationTitle() {
        txtLocationName.text = self.game.locationName
    }
    
    func setGameAddress(_ address: String) {
        self.address = address
        lblAddress.text = address
    }
    
    //MARK: - User Input Validation
    fileprivate func enteredDataIsValid() -> Bool {
        
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
    
    fileprivate func markInvalidFields() {
        
        if self.game.totalSlots == 0 {
            let indexPath = IndexPath(row: 2, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                animateCellValidation(cell)
            }
        }
        
        if self.game.latitude == 0.0 {
            let indexPath = IndexPath(row: 2, section: 1)
            if let cell = tableView.cellForRow(at: indexPath) {
                animateCellValidation(cell)
            }

        }
        
        if self.game.locationName == "" {
            let indexPath = IndexPath(row: 2, section: 1)
            if let cell = tableView.cellForRow(at: indexPath) {
                animateCellValidation(cell)
            }
            txtLocationName.becomeFirstResponder()
        }
        
    }
    
    //MARK: - Parse
    
    fileprivate func getGameObjectFromParse() {
        
        print("Getting game object from Parse")
        let gameQuery = PFQuery(className:"Game")
        gameQuery.getObjectInBackground(withId: self.game.id) {
            (gameObject: PFObject?, error: Error?) -> Void in
            if error == nil && gameObject != nil {
                self.gameObject = gameObject
                print("Game object set successfully")
            } else {
                self.gameObject = nil
            }
        }
    }
    
    fileprivate func saveParseGameObject() {
        
        var gameObject: PFObject
        //TODO: - Figure out how to save the PFObject back - or at least why it's not being saved
        
        if gameStatus == .create {
            gameObject = PFObject(className: "Game")
            
        } else { //gameStatus == .EDIT
            gameObject = self.gameObject
        }
        
        setGameObjectFields(gameObject)
        saveGameObjectInBackground(gameObject)

    }
    
    fileprivate func setGameObjectFields(_ gameObject: PFObject) {
        
//        gameObject["gameType"] = PFObject(withoutDataWithClassName: "GameType", objectId: self.game.gameType.id)
        gameObject["gameType"] = PFObject(withoutDataWithClassName: "GameType", objectId: self.game.gameType.id)
        
        gameObject["date"] = self.game.eventDate
        let point = PFGeoPoint(latitude:self.game.latitude, longitude: self.game.longitude)
        gameObject["location"] = point
        gameObject["locationName"] = self.game.locationName
        gameObject["gameNotes"] = self.game.gameNotes
        gameObject["totalSlots"] = self.game.totalSlots
        gameObject["slotsAvailable"] = self.game.availableSlots
        
        if gameStatus == .create {
            gameObject["owner"] = PFUser.current()
            gameObject["isCancelled"] = false
            gameObject.relation(forKey: "players").add(PFUser.current()!)
        }
    }
    
    fileprivate func saveGameObjectInBackground (_ gameObject: PFObject) {
        print("Saving object in background with block")
        gameObject.saveInBackground {
            (success: Bool, error: Error?) -> Void in
            if (success) {
                
                let gameId = gameObject.objectId! as String
                self.game.id = gameId
                
                if self.gameStatus == GameStatus.create {
                    print("Game is new")
                    LocalNotifications.scheduleGameNotification(self.game)
                    self.game.gameType.increaseGameCount(1)
                    self.addGameToUserDefaults(gameId)
                    self.dismissalDelegate?.setNewGame(self.game)
                    self.dismissalDelegate?.finishedShowing(self)
                } else {
                    print("Game is edited")
                    self.gameDetailsDelegate.setGame(self.game)
                    self.dismiss(animated: true, completion: nil)
                }
                
            } else {
                //TODO: Add some sort of alert to say that the game could not be saved
            }
        }
    }
    
    //MARK: - User Defaults
    
    fileprivate func addGameToUserDefaults(_ gameId: String) {
        
        if let joinedGames = UserDefaults.standard.object(forKey: "userJoinedGamesById") as? NSArray {
            let gameIdArray = joinedGames.mutableCopy()
            (gameIdArray as AnyObject).add(gameId)
            UserDefaults.standard.set(gameIdArray, forKey: "userJoinedGamesById")
        } else {
            var gameIdArray: [String] = []
            gameIdArray.append(gameId)
            UserDefaults.standard.set(gameIdArray, forKey: "userJoinedGamesById")
        }
        
    }
    
    //MARK: - Date Time
    
    func earliestSuggestedGameTime() -> Date {
        let calendar = Calendar.current
        let date = Date()
        let minuteComponent = (calendar as NSCalendar).components([.minute], from: date)
        let remainder = minuteComponent.minute! % 10
        let minutesToAdd: Int
        if remainder < 5 {
            minutesToAdd = 10 - remainder
        } else {
            minutesToAdd = 15 - remainder
        }
        
        var components = DateComponents()
        components.minute = minutesToAdd
        return (calendar as NSCalendar).date(byAdding: components, to: date, options: .matchFirst)!
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SEGUE_NEW_GAME_MAP {
            
            let newGameMapViewController = segue.destination as? NewGameMapViewController
            
            newGameMapViewController?.newGameTableViewDelegate = self
            
            if self.game.locationName != "" && self.game.latitude != 0.0 {
                newGameMapViewController?.locationName = self.game.locationName
                newGameMapViewController?.gameLocation = CLLocationCoordinate2DMake(self.game.latitude, self.game.longitude)
            }
        }
        
    }
}
