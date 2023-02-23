//
//  CustomButton.swift
//  WebsiteFilter
//
//  Created by Beavean on 23.02.2023.
//

import UIKit

final class CustomButton: UIButton {
    private let elementsSize: CGFloat = 44

    init(title: String) {
        super.init(frame: .zero)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: elementsSize),
            .foregroundColor: UIColor.white
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributedTitle, for: .normal)
        contentHorizontalAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: elementsSize).isActive = true
        heightAnchor.constraint(equalToConstant: elementsSize).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func changeTitle(to title: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: elementsSize),
            .foregroundColor: UIColor.white
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributedTitle, for: .normal)
    }
}
