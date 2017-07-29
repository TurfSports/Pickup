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
        dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let date = dayTimePeriodFormatter.date(from: string)!
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        let finalDate = calendar.date(from:components)
        
        return finalDate!
    }
}
