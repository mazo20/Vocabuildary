//
//  UITableViewCell+Identifier.swift
//  Vocabuildary
//
//  Created by Bartosz Olszanowski on 01/09/16.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    class func identifier() -> String! {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
}