//
//  Extensions.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 26.06.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

public func blueThemeColor() -> UIColor {
    return UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
}
// TIP: Pamiętaj o odstępach między funkcjami!
public func timeFormatter(time: NSTimeInterval) -> String {
    let hours = time/3600
    let minutes = time%3600/60
    let seconds = time%60
    
    if hours > 1 {
        return "\(Int(hours))h \(Int(minutes))m"
    } else if minutes > 1 {
        return "\(Int(minutes))m \(Int(seconds))s"
    } else {
        return "\(Int(seconds))s"
    }
}

public func printD(date: NSDate) {
    // Formatowanie
    let formatter           = NSDateFormatter()
    formatter.dateFormat    = "yyyy-MM-dd HH:mm:ss ZZZ"
    let defaultTimeZoneStr  = formatter.stringFromDate(date)
    print(defaultTimeZoneStr)
}

public func stringFromDate(date: NSDate) -> String {
    let day = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: date).day
    let month = NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: date).month
    let year = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: date).year
    return "\(year)-\(dateComponentFormatter(month))-\(dateComponentFormatter(day))"
}

public func dateComponentFormatter(component: Int) -> String {
    if component >= 10 {
        return "\(component)"
    }
    return "0\(component)"
}

extension NSDate {
    var today: NSDate {
        let date = NSDate()
        let dateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: date)
        let today = NSCalendar.currentCalendar().dateFromComponents(dateComponents)
        return today!
    }
}