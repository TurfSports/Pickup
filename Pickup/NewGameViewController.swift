//
//  NewGameTableViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/17/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit

class NewGameTableViewController: UITableViewController, UIPickerViewDelegate {

    var gameTypes: [GameType]!
    
    @IBOutlet weak var lblSport: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var lblDate: UILabel!
    
    var dateRowSelected:Bool = false
    
    //TODO: Constrain the date picker to disallow scheduling beyond the following week
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        lblDate.text = DateUtilities.dateString(sender.date, dateFormatString: "\(DateFormatter.MONTH_ABBR_AND_DAY.rawValue)  \(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gameTypes.count
    }

    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gameTypes[row].displayName
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lblSport.text = gameTypes[row].displayName
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 {
            dateRowSelected = !dateRowSelected
            animateReloadTableView()
        }
        
        if indexPath.section == 0 {
            
        }
        
        if indexPath.section != 1 && dateRowSelected == true {
            dateRowSelected = !dateRowSelected
            animateReloadTableView()
        }
    }
    
    //TODO: Animate this
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 44.0
        
        if indexPath.section == 1 && indexPath.row == 1 {
            if dateRowSelected == false {
                datePicker.hidden = true
                rowHeight = 0.0
            } else {
                datePicker.hidden = false
                rowHeight = 220.0
            }
            
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
