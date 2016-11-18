//
//  CardsNumberCell.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 20.05.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class CardsNumberCell: UITableViewCell {
    
    @IBOutlet var problematicCards: UILabel!
    @IBOutlet var repeatingCards: UILabel!
    @IBOutlet var newCards: UILabel!
    
    @IBOutlet var line1: UIView!
    @IBOutlet var line2: UIView!
    override func draw(_ rect: CGRect) {
        line1.layer.cornerRadius = 30
        line2.layer.cornerRadius = 30
    }
}
