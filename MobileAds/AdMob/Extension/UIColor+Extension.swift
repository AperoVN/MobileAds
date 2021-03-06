//
//  UIColor+Extension.swift
//  MobileAds
//
//  Created by ANH VU on 28/04/2022.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
    
    convenience init(hex: Int,  alpha: CGFloat = 1.0) {
        self.init(red: ((hex >> 16) & 0xFF), green: ((hex >> 8) & 0xFF), blue: (hex & 0xFF), alpha: alpha)
    }
}

