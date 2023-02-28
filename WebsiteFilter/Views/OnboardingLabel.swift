//
//  OnboardingLabel.swift
//  WebsiteFilter
//
//  Created by Beavean on 28.02.2023.
//

import UIKit

final class OnboardingLabel: UILabel {
    // swiftlint:disable line_length
    private let title = """
                        Enter a URL into the text field and tap \"Search\" on your keyboard to open a web page or search word in Google
                        """

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        text = title
        textColor = .lightGray
        numberOfLines = 0
        textAlignment = .center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
