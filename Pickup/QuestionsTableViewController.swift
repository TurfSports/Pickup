//
//  QuestionsTableViewController.swift
//  Pickup
//
//  Created by Justin Carver on 8/4/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import UIKit
import FirebaseAuth

class QuestionsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var agePicker: UIPickerView!
    @IBOutlet var ageTextView: UILabel!
    @IBOutlet var genderSegmentedController: UISegmentedControl!
    @IBOutlet var chooseAPictureButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextView: UITextField!
    @IBOutlet var passwordTextView: UITextField!
    
    var email: String = ""
    var password: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var ageRange: [Int] = []
    var pickerIsHidden = true
    var age: Int?
    var image: UIImage?
    var needsEmailAndPassword: Bool = true
    var gender: String = ""
    var numberOfSections = 5
    var sectionsRemaining = ["1", "2", "3", "4", "5"]
    var hasDeletedSections = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismiss(animated: true, completion: nil)
        agePicker.delegate = self
        agePicker.dataSource = self
        agePicker.isHidden = pickerIsHidden
        for age in 10...90 {
            ageRange.append(age)
        }
        hideFilledSections()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - Hide already filled in information
    
    func hideFilledSections() {
        
        guard hasDeletedSections != true else { return }
        self.hasDeletedSections = !self.hasDeletedSections
        
        if gender != "" {
            genderSegmentedController.isHidden = true
            tableView.deleteSections(IndexSet.init(integer: IndexSet.Element.init(4)), with: .none)
            self.numberOfSections -= 1
            self.sectionsRemaining.remove(at: 4)
        }
        
        if age != nil {
            ageTextView.isHidden = true
            tableView.deleteSections(IndexSet.init(integer: IndexSet.Element.init(3)), with: .none)
            self.numberOfSections -= 1
            self.sectionsRemaining.remove(at: 3)
            
        }
        
        if image != nil {
            imageView.isHidden = true
            tableView.deleteSections(IndexSet.init(integer: IndexSet.Element.init(2)), with: .none)
            self.numberOfSections -= 1
            self.sectionsRemaining.remove(at: 2)
        }
        
        if firstName != "", firstName != "firstName" {
            firstNameTextField.isHidden = true
            let firstNameIndexPath = IndexPath.init(row: 0, section: 1)
            self.tableView.deleteRows(at: [firstNameIndexPath], with: .none)
        }
        
        if lastName != "", lastName != "lastName" {
            lastNameTextField.isHidden = true
            let lastNameIndexPath = IndexPath.init(row: 1, section: 1)
            self.tableView.deleteRows(at: [lastNameIndexPath], with: .none)
        }
        
        if firstName != "", lastName != "" && firstName != "firstName", lastName != "lastName" {
            tableView.deleteSections(IndexSet.init(integer: IndexSet.Element.init(1)), with: .none)
            self.numberOfSections -= 1
            self.sectionsRemaining.remove(at: 1)
        }
        
        if needsEmailAndPassword == false {
            passwordTextView.isHidden = true
            emailTextView.isHidden = true
            tableView.deleteSections(IndexSet.init(integer: IndexSet.Element.init(0)), with: .none)
            self.numberOfSections -= 1
            self.sectionsRemaining.remove(at: 0)
        }
        
        if tableView.numberOfSections == 0 {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Delegates and data sources
    
    //MARK: Data Sources
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfSections
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ageRange.count
    }
    
    //MARK: Delegates
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let age = ageRange[row]
        let stringOfAge = "\(age)"
        return stringOfAge
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let age = ageRange[row]
        ageTextView.text = "\(age)"
        self.age = age
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard sectionsRemaining.contains("4") else { tableView.deselectRow(at: indexPath, animated: true); return }
        
        guard indexPath.section == 3 && indexPath.row == 0 else { tableView.deselectRow(at: indexPath, animated: true); return }
        
        pickerIsHidden = !pickerIsHidden
        agePicker.isHidden = pickerIsHidden
        agePicker.selectRow(11, inComponent: 0, animated: true)
        animateTableView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let picturePickerIsHidden = !sectionsRemaining.contains("3")
        let nameIsVisable = sectionsRemaining.contains("2")
        let emailIsVisable = sectionsRemaining.contains("1")
        
        if numberOfSections == 5 {
            if indexPath.section == 3 && indexPath.row == 0 {
                guard pickerIsHidden != true else { return 0 }
                return 120
            } else if indexPath.section == 2 {
                return 140
            } else {
                return 44
            }
        }
        
        if !picturePickerIsHidden && emailIsVisable && nameIsVisable && indexPath.section == 2 {
            return 140
        } else if !picturePickerIsHidden && emailIsVisable || nameIsVisable && indexPath.section == 1 {
            return 140
        } else if !picturePickerIsHidden && !emailIsVisable && !nameIsVisable && indexPath.section == 0 {
            return 140
        }
        
        guard sectionsRemaining.contains("4") else { return 44 }
        
        guard indexPath.section == 3 && indexPath.row == 0 else { return 44 }
        
        guard pickerIsHidden != true else { return 0 }
        return 120
    }
    
    func animateTableView() {
        UIView.transition(with: tableView, duration:0.2, options: [.allowAnimatedContent, .transitionCrossDissolve], animations: { () -> Void in
            self.tableView.reloadData()
        }, completion: nil);
    }
    
    //==========================================================================
    //  MARK: - Actions
    //==========================================================================
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let genders = ["Male", "Female", "Undisclosed"]
        
        guard let email = self.emailTextView.text else { presentAlertController(with: "Please check that you have input your email and try again", and: []); return }
        guard email != "" || needsEmailAndPassword == false else { presentAlertController(with: "Please check that you have input your email and try again", and: []); return }
        guard email.characters.contains("@") && (email.characters.last == "m" || email.characters.last == "t") || needsEmailAndPassword == false else { presentAlertController(with: "Please check that you have input a valid email and try again", and: []); return }
        guard let password = passwordTextView.text, password != "" || needsEmailAndPassword == false else { presentAlertController(with: "Please check that you have input a password", message: "It is recomended that your password has one number and  one uppercase letter", and: []); return }
        guard let age = self.age else { presentAlertController(with: "Please check that you have input your age and try again", and: []); return }
        guard let firstName = firstNameTextField.text, firstName != "" else { presentAlertController(with: "Please check that you have input your first name and try again", and: []); return }
        guard (lastNameTextField.text?.characters.count)! >= 2, var lastName = lastNameTextField.text, lastName != "" else { self.presentAlertController(with: "Please check that you have input your last name and try again", and: []); return }
        
        let gender = genders[genderSegmentedController.selectedSegmentIndex]
        
        if imageView.image == nil {
            
            let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (_) in
                currentPlayer.userImage = nil
                currentPlayer.age = "\(age)"
                currentPlayer.firstName = firstName
                currentPlayer.lastInitials = "\(lastName.characters.first ?? "a")"
                let firstCharacterIndex = lastName.characters.index(of: lastName.characters.first!)
                let secondCharacterIndex = lastName.characters.index(after: firstCharacterIndex!)
                let secondCharacter = lastName.characters[secondCharacterIndex]
                currentPlayer.lastInitials += "\(secondCharacter)"
                currentPlayer.gender = gender
                Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                    if let uid = user?.uid {
                        currentPlayer.id = uid
                    }
                })
                self.dismiss(animated: true, completion: nil)
            }
            
            let noAction = UIAlertAction.init(title: "No", style: .cancel) { (_) in
                return
            }
            
            presentAlertController(with: "You have not input a profile picture.", message: "Are you sure you want to continue?", and: [yesAction, noAction])
        }
        
        let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (_) in
            currentPlayer.age = "\(age)"
            currentPlayer.firstName = firstName
            currentPlayer.lastInitials = "\(lastName.characters.first ?? "a")".capitalized
            let firstCharacterIndex = lastName.characters.index(of: lastName.characters.first!)
            let secondCharacterIndex = lastName.characters.index(after: firstCharacterIndex!)
            let secondCharacter = lastName.characters[secondCharacterIndex]
            currentPlayer.lastInitials += "\(secondCharacter)".lowercased()
            currentPlayer.gender = gender
            currentPlayer.userImage = self.imageView.image!
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if let uid = user?.uid {
                    currentPlayer.id = uid
                }
            })
            self.dismiss(animated: true, completion: nil)
        }
        
        let noAction = UIAlertAction.init(title: "No", style: .cancel)
        
        presentAlertController(with: "Are you sure you would like to continue?", message: "You may change any information later if needed.", and: [yesAction, noAction])
    }
    
    func presentAlertController(with string: String, message: String = "", and actions: [UIAlertAction]) {
        let alertController = UIAlertController.init(title: string, message: message, preferredStyle: .alert)
        if actions == [] {
            let okAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(okAction)
        } else {
            for action in actions {
                alertController.addAction(action)
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func chooseAPictureButtonTapped(_ sender: Any) {
        setupImagePicker()
    }
    
    //==========================================================================
    //  MARK: - Image Picker
    //==========================================================================
    
    func setupImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) -> Void in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) -> Void in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            delegate?.photoSelectViewControllerSelected(image: image)
            chooseAPictureButton.setTitle("", for: .normal)
            imageView.image = image
        }
    }
    
    weak var delegate: PhotoSelectViewControllerDelegate?
}


protocol PhotoSelectViewControllerDelegate: class {
    
    func photoSelectViewControllerSelected(image: UIImage)
}
