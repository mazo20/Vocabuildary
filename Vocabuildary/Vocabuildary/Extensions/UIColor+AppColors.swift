//
//  UIColor+AppColors.swift
//  Vocabuildary
//
//  Created by Bartosz Olszanowski on 31/08/16.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    // Sa dwie metody zeby stworzyc taka zmienna pomocnicza jako extension do jakiejs klasy
    
    // 1. Zmienna statyczna
    public static var vocab_themeBlueColor: UIColor {
        return UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
    }
    // Wywolujesz jako: UIColor.vocab_themeBlueColor
    
    // 2. Klasa statyczna
    public class func vocab_themeRedColor() -> UIColor {
        return UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
    }
    // Wywolujesz jako: UIColor.vocab_themeRedColor()
    
    // Ogolnie chcialem Ci pokazac, ze do extensions mozesz dodawac zarowno vary jak i funkcje
    // Jezeli nie dodasz slowek static / class to tez mozna to tak zadeklarowac, ale wtedy funkcja / zmienna musi byc wywolana na instancji klasy a nie na samej klasie.
    
}