//
//  URLTextField.swift
//  WebsiteFilter
//
//  Created by Beavean on 24.02.2023.
//

import UIKit

final class URLTextField: UITextField {
    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Private Methods

    private func setup() {
        borderStyle = .roundedRect
        clearButtonMode = .always
        textContentType = .URL
        backgroundColor = .clear
        autocorrectionType = .no
        autocapitalizationType = .none
        spellCheckingType = .no
        keyboardType = .URL
        smartQuotesType = .no
        returnKeyType = .search
        clearButtonMode = .always
        tintAdjustmentMode = .normal
        leftViewMode = .always
        font = UIFont.systemFont(ofSize: 18)
        placeholder = "Enter URL"
    }
}
