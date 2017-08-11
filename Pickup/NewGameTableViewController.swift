//
//  NewGameTableViewController.swift
//  Pickup
//
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

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

    var game: Game?
    
    var gameObject: [String: Any]!
    
    var selectedGameType: GameType!
    
    var gameTypes: [GameType] = loadedGameTypes
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
    
    func save(game: Game, completion: @escaping (Bool) -> Void) {
        
        GameController.shared.put(game: game, with: game.id, to: nil, success: { (success) in
            completion(success)
            if success == false {
                print("Error saving")
                let alertController: UIAlertController = UIAlertController.init(title: "Error saving your game. Please try again.", message: "Ok", preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func createNewGame(_ sender: UIBarButtonItem) {
        
        if editingNotes == false  {
            if enteredDataIsValid() == true {
                self.game?.gameNotes = txtGameNotes.text
                if selectedGameType == nil { game?.gameType = loadedGameTypes[0] }
                else { self.game?.gameType = self.selectedGameType }
                if let game = self.game {
                    save(game: game, completion: { (success) in
                        if success {
                            print("Put Game")
                        }
                    })
                } else {
                    let alertController = UIAlertController.init(title: "There was a problem saving your game, please check your connection and try again", message: "", preferredStyle: .alert)
                    let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (nil) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    let tryAgainAction = UIAlertAction.init(title: "Try Again", style: .default)
                    
                    alertController.addAction(cancelAction)
                    alertController.addAction(tryAgainAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
                if !NotificationsManager.notificationsInitiated() {
                    NotificationsManager.registerNotifications()
                }
                
            } else {
                markInvalidFields()
            }
        } else {
            self.game?.gameNotes = txtGameNotes.text
            self.txtGameNotes.resignFirstResponder()
            
            if gameStatus == .create {
                btnCreate.title = "Create"
            } else {
                btnCreate.title = "Save"
            }
            
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        
        
        lblDate.text = DateUtilities.dateString(sender.date, dateFormat: "\(DateFormatter.MONTH_ABBR_AND_DAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
        
        if self.gameObject != nil {
            self.gameObject["eventDate"] = sender.date
        }
        
        self.game?.eventDate = sender.date
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            
        self.gameTypes = loadedGameTypes
        
        self.createDefaultGame()
            
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
        
        if let game = self.game {
            self.MIN_PLAYERS = game.totalSlots - game.availableSlots - 1
            if self.MIN_PLAYERS < 1 {
                self.MIN_PLAYERS = 1
            }
        }

        self.btnCancel.tintColor = Theme.PRIMARY_LIGHT_COLOR
        self.btnCreate.tintColor = Theme.ACCENT_COLOR
        self.btnMap.tintColor = Theme.ACCENT_COLOR
//        self.removeTopWhiteSpace()

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
        
        guard let game = self.game else { return }
        
        lblSport.text = game.gameType.displayName
        sportPicker.selectRow(game.gameType.sortOrder, inComponent: 0, animated: false)
        
        lblPlayers.text = "\(game.totalSlots - 1)"
        numberOfPlayersPicker.selectRow(game.availableSlots, inComponent: 0, animated: false)
        
        datePicker.date = game.eventDate as Date
        lblDate.text = DateUtilities.dateString(datePicker.date, dateFormat: "\(DateFormatter.MONTH_ABBR_AND_DAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
        
        txtLocationName.text = game.locationName
        
        if address != nil {
            lblAddress.text = address
        }
        
        txtGameNotes.text = game.gameNotes
    }
    
    fileprivate func createDefaultGame() {
        
        DispatchQueue.main.async {
            
        if self.address == nil {
            self.setGameAddress("")
        }
        
        let defaultGameType: GameType
        if self.selectedGameType == nil {
            defaultGameType = loadedGameTypes[0]
        } else {
            defaultGameType = self.selectedGameType
        }
        
        self.numberOfPlayersPicker.selectRow(9, inComponent: 0, animated: false)
            
        // TODO: - Add default user
        
        let game = Game.init(id: UUID.init(), gameType: defaultGameType, totalSlots: 0, availableSlots: 0, eventDate: Date.init(), locationName: self.address!, ownerId: "userID", userIDs: [], gameNotes: "")
        game.userIsOwner = true
        game.userJoined = true
            // Insert user id
        game.ownerId = "_userID"
            
        self.game = game
        }
    }
    
    fileprivate func setDefaultInitialValues() {
        
        guard let game = self.game else { return }
        
        DispatchQueue.main.async {
        
        self.lblPlayers.text = ""
        
        self.lblSport.text = game.gameType.displayName
        self.sportPicker.selectRow(game.gameType.sortOrder, inComponent: 0, animated: false)
        
        //Round to second nearest five minute increment
        self.datePicker.date = self.earliestSuggestedGameTime()
        self.lblDate.text = DateUtilities.dateString(self.datePicker.date, dateFormat: "\(DateFormatter.MONTH_ABBR_AND_DAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
        }
    }
    
//    func removeTopWhiteSpace() {
//        let dummyViewHeight: CGFloat = 40
//        let dummyView:UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
//        self.tableView.tableHeaderView = dummyView
//        self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0)
//    }
    
    
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
                self.game?.gameType = gameTypes[row]
                lblSport.text = gameTypes[row].displayName
                self.selectedGameType = gameTypes[row]
                break
            case NUMBER_OF_PLAYERS_PICKER:
                
                if self.gameObject != nil {
                    self.gameObject["totalSlots"] = row + MIN_PLAYERS + 1
                    self.gameObject["availableSlots"] = row + MIN_PLAYERS
                }
                
                self.game?.totalSlots = row + MIN_PLAYERS + 1
                self.game?.availableSlots = row + MIN_PLAYERS
                
                lblPlayers.text = "\(row + MIN_PLAYERS)"
                break
            default:
                break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.white
        
        if (indexPath as IndexPath).section == 0 && (indexPath as IndexPath).row == 0 && gameStatus == .create {
            sportRowSelected = !sportRowSelected
            dateRowSelected = false
            playerRowSelected = false
            animateReloadTableView()
        } else if (indexPath as IndexPath).section == 0 && (indexPath as IndexPath).row == 2 {
            playerRowSelected = !playerRowSelected
            if lblPlayers.text == "" || lblPlayers.text == nil {
                lblPlayers.text = "\(numberOfPlayersPicker.selectedRow(inComponent: 0) + 1)"
                self.game?.totalSlots = numberOfPlayersPicker.selectedRow(inComponent: 0) + 1
                self.game?.availableSlots = numberOfPlayersPicker.selectedRow(inComponent: 0)
            }
            sportRowSelected = false
            dateRowSelected = false
        } else if (indexPath as IndexPath).section == 1 && (indexPath as IndexPath).row == 0 {
            dateRowSelected = !dateRowSelected
            sportRowSelected = false
            playerRowSelected = false
        } else if (indexPath as IndexPath).section == 1 && (indexPath as IndexPath).row == 2 {
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
        
        if (indexPath as IndexPath).section == 0 && (indexPath as IndexPath).row == 1 {
            if sportRowSelected == false {
                rowHeight = 0.0
            } else {
                rowHeight = 130.0
            }
        }
        
        if (indexPath as IndexPath).section == 0 && (indexPath as IndexPath).row == 3 {
            if playerRowSelected == false {
                rowHeight = 0.0
            } else {
                rowHeight = 130.0
            }
        }
        
        if (indexPath as IndexPath).section == 1 && (indexPath as IndexPath).row == 1 {
            if dateRowSelected == false {
                datePicker.isHidden = true
                rowHeight = 0.0
            } else {
                datePicker.isHidden = false
                rowHeight = 220.0
            }
        }
        
        if (indexPath as IndexPath).section == 1 && (indexPath as IndexPath).row == 2 {
            if address != nil {
                rowHeight = 115
            }
        }
        
        if (indexPath as IndexPath).section == 2 && (indexPath as IndexPath).row == 0 {
            DispatchQueue.main.async {
                rowHeight = self.gameNotesTableViewHeight
            }
        }
        
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if (indexPath as IndexPath).section == 0 && (indexPath as IndexPath).row == 0 && self.gameStatus == .edit {
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
        self.game?.locationName = textField.text!
        if self.game?.locationName != "" {
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
        self.game?.gameNotes = textView.text
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
        self.game?.latitude = coordinate.latitude
        self.game?.longitude = coordinate.longitude
    }
    
    func setGameLocationName(_ locationName: String) {
        
        txtLocationName.isHidden = false
        txtLocationName.isEnabled = true
        self.game?.locationName = locationName
        txtLocationName.text = locationName
        txtLocationName.becomeFirstResponder()
    }
    
    func setLocationTitle() {
        txtLocationName.text = self.game?.locationName
    }
    
    func setGameAddress(_ address: String) {
        self.address = address
        lblAddress.text = address
    }
    
    //MARK: - User Input Validation
    fileprivate func enteredDataIsValid() -> Bool {
        
        var isValid = true
        
        if self.game?.totalSlots == 0 {
            isValid = false
        }
        
        if self.game?.locationName == "" {
            isValid = false
        }
        
        if self.game?.latitude == 0.0 {
            isValid = false
        }
        
        return isValid
    }
    
    fileprivate func markInvalidFields() {
        
        if self.game?.totalSlots == 0 {
            let indexPath = IndexPath(row: 2, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                animateCellValidation(cell)
            }
        }
        
        if self.game?.latitude == 0.0 {
            let indexPath = IndexPath(row: 2, section: 1)
            if let cell = tableView.cellForRow(at: indexPath) {
                animateCellValidation(cell)
            }

        }
        
        if self.game?.locationName == "" {
            let indexPath = IndexPath(row: 2, section: 1)
            if let cell = tableView.cellForRow(at: indexPath) {
                animateCellValidation(cell)
            }
            txtLocationName.becomeFirstResponder()
        }
        
    }
    
    //MARK: - Parse
    
    fileprivate func getGameObjectFromParse() {
        /*
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
        */
    }
    
    /*
    fileprivate func saveGame() {
        
        var gameObject: [String: Any]
        //TODO: - Figure out how to save the PFObject back - or at least why it's not being saved
        
        if gameStatus == .create {
            // Create a game
            
        } else { //gameStatus == .EDIT
            gameObject = self.gameObject
        }
        
//        setGameObjectFields(gameObject)
//        saveGameObjectInBackground(gameObject)

    }
    
    
    // Parse Save

    
    fileprivate func setGameObjectFields(_ gameObject: ) {
        
        gameObject["gameType"] = PFObject(withoutDataWithClassName: "GameType", objectId: self.game.gameType.id)
        
        gameObject["date"] = self.game.eventDate
        let point = (latitude:self.game.latitude, longitude: self.game.longitude)
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
   
    
    fileprivate func saveGameObjectInBackground (_ gameObject: Any) {
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
     */
    
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
            
            if self.game?.locationName != "" && self.game?.latitude != 0.0 {
                guard let game = self.game else { return }
                newGameMapViewController?.locationName = game.locationName
                newGameMapViewController?.gameLocation = CLLocationCoordinate2DMake(game.latitude, game.longitude)
            }
        }
        
    }
}
