//
//  Extensions.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 26.06.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

protocol TimeFormatable {
}
extension TimeFormatable {
    func timeFormatter(_ time: TimeInterval) -> String {
        let hours = time/3600
        let minutes = time.truncatingRemainder(dividingBy: 3600)/60
        let seconds = time.truncatingRemainder(dividingBy: 60)
        
        if hours > 1 {
            return "\(Int(hours))h \(Int(minutes))m"
        } else if minutes > 1 {
            return "\(Int(minutes))m \(Int(seconds))s"
        } else {
            return "\(Int(seconds))s"
        }
    }
}
extension UIColor {
    class func blueThemeColor() -> UIColor {
        return UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
    }
}

public func blueThemeColor() -> UIColor {
    return UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
}
public func printD(_ date: Date) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
    let defaultTimeZoneStr = formatter.string(from: date)
    print(defaultTimeZoneStr)
}
public func stringFromDate(_ date: Date) -> String {
    let day = (Calendar.current as NSCalendar).components(NSCalendar.Unit.day, from: date).day
    let month = (Calendar.current as NSCalendar).components(NSCalendar.Unit.month, from: date).month
    let year = (Calendar.current as NSCalendar).components(NSCalendar.Unit.year, from: date).year
    return "\(year)-\(dateComponentFormatter(month!))-\(dateComponentFormatter(day!))"
}
public func dateComponentFormatter(_ component: Int) -> String {
    if component >= 10 {
        return "\(component)"
    }
    return "0\(component)"
}
extension Date {
    var today: Date {
        let date = Date()
        let dateComponents = (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: date)
        let today = Calendar.current.date(from: dateComponents)
        return today!
    }
}
extension UINavigationController {
    open override func viewDidLoad() {
        let lineView = UIView(frame: CGRect(x: 0, y: self.navigationBar.frame.size.height, width: self.navigationBar.frame.size.width, height: 1))
        lineView.backgroundColor = blueThemeColor()
        self.navigationBar.addSubview(lineView)
    }
}
