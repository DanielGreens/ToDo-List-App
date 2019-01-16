//
//  LoginTextField.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 16/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

@IBDesignable
class LoginTextField: UITextField {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderColor = UIColor(white: 231/255, alpha: 1).cgColor
        self.layer.borderWidth = 1
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 8, dy: 7)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

}
