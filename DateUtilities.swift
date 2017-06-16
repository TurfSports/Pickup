//
//  DateUtilities.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/19/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

struct DateUtilities {
    
    static func dateString(_ date: Date, dateFormat: String) -> String {
        
        let dayTimePeriodFormatter = Foundation.DateFormatter()
        dayTimePeriodFormatter.dateFormat = dateFormat
        
        return dayTimePeriodFormatter.string(from: date)
    }
    
    static func dateFrom(_ string: String, dateFormat: String) -> Date {
        
        let dayTimePeriodFormatter = Foundation.DateFormatter()
        dayTimePeriodFormatter.dateFormat = dateFormat
        
        guard let date = dayTimePeriodFormatter.date(from: string) else { return Date() }
        
        return date
    }
}
