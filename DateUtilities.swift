//
//  DateUtilities.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/19/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

struct DateUtilities {
    
    static func dateString(date: NSDate, dateFormatString: String) -> String {
        
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = dateFormatString
        
        return dayTimePeriodFormatter.stringFromDate(date)
    }
    
}
