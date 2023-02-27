//
//  UIView+BorderRadius.swift
//  WebsiteFilter
//
//  Created by Beavean on 23.02.2023.
//

import UIKit

extension UIView {
    func addRoundedBorder() {
        layer.cornerRadius = 5
        layer.borderColor = UIColor.tintColor.cgColor
        layer.borderWidth = 2
    }
}
