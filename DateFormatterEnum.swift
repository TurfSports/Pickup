//
//  DateFormatterEnum.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/19/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

//  This enum abstracts out Swift's date abbreviations

public enum DateFormatter: String {
    case MONTH_ABBR_AND_DAY = "MMM d"
    case TWELVE_HOUR_TIME = "h:mm a"
    case WEEKDAY = "E"
}
