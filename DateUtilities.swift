//
//  DateUtilities.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/19/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

struct DateUtilities {
    
    static func dateString(_ date: Date, dateFormatString: String) -> String {
        
        let dayTimePeriodFormatter = Foundation.DateFormatter()
        dayTimePeriodFormatter.dateFormat = dateFormatString
        
        return dayTimePeriodFormatter.string(from: date)
    }
    
}
