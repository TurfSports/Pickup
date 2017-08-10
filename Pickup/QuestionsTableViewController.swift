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
    
    var ageRange: [Int] = []
    var pickerIsHidden = true
    var image: UIImage?
    var age: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        agePicker.delegate = self
        agePicker.dataSource = self
        agePicker.isHidden = pickerIsHidden
        for age in 10...90 {
            ageRange.append(age)
        }
    }
    
    //MARK: - Delegates and data sources
    
    //MARK: Data Sources
    
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
        if indexPath.section == 3 && indexPath.row == 0 {
            pickerIsHidden = !pickerIsHidden
            agePicker.isHidden = pickerIsHidden
            agePicker.selectRow(11, inComponent: 0, animated: true)
            animateTableView()
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 && indexPath.row == 1 {
            guard pickerIsHidden != true else { return 0 }
            return 120
        } else if indexPath.section == 2 {
            return 140
        } else {
            return 44
        }
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
        guard email != "" else { presentAlertController(with: "Please check that you have input your email and try again", and: []); return }
        guard email.characters.contains("@") && (email.characters.last == "m" || email.characters.last == "t") else { presentAlertController(with: "Please check that you have input a valid email and try again", and: []); return }
        guard let password = passwordTextView.text, password != "" else { presentAlertController(with: "Please check that you have input a password", message: "It is recomended that your password has one number and  one uppercase letter", and: []); return }
        guard let age = self.age else { presentAlertController(with: "Please check that you have input your age and try again", and: []); return }
        guard let firstName = firstNameTextField.text, firstName != "" else { presentAlertController(with: "Please check that you have input your first name and try again", and: []); return }
        guard (lastNameTextField.text?.characters.count)! >= 1, let lastName = lastNameTextField.text, lastName != "" else { self.presentAlertController(with: "Please check that you have input your last name and try again", and: []); return }
        
        let gender = genders[genderSegmentedController.selectedSegmentIndex]
        
        if imageView.image == nil {
            
            let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (_) in
                currentPlayer.userImage = nil
                currentPlayer.age = "\(age)"
                currentPlayer.firstName = firstName
                currentPlayer.lastName = lastName
                currentPlayer.email = email
                currentPlayer.gender = gender
                currentPlayer.password = password
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
            currentPlayer.lastName = lastName
            currentPlayer.email = email
            currentPlayer.gender = gender
            currentPlayer.userImage = self.imageView.image!
            currentPlayer.password = password
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
