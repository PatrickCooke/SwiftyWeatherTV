//
//  RoundedTextView.swift
//  SwiftyWeather
//
//  Created by Patrick Cooke on 5/26/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedTextView: UITextView {

    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
}
