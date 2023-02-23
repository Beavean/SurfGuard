//
//  UIView+BorderRadius.swift
//  WebsiteFilter
//
//  Created by Beavean on 23.02.2023.
//

import UIKit

extension UIView {
    func addCornerRadiusBasedOnSize() {
        layer.masksToBounds = true
        let cornerRadius = min(bounds.width, bounds.height) / 5
        layer.cornerRadius = cornerRadius
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }
}
