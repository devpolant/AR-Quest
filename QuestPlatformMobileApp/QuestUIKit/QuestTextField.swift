//
//  QuestTextField.swift
//  QuestPlatformMobileApp
//
//  Created by Anton Poltoratskyi on 25.02.2018.
//  Copyright © 2018 Anton Poltoratskyi. All rights reserved.
//

import UIKit

class QuestTextField: UITextField {
    
    override var placeholder: String? {
        didSet {
            guard let placeholder = placeholder else { return }
            let attributes: [NSAttributedStringKey: Any] = [
                .foregroundColor: Theme.TextField.Color.placeholder,
                .font: Theme.TextField.Font.default
            ]
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
    }
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    
    // MARK: - UI Setup
    
    private func setupSubviews() {
        backgroundColor = Theme.TextField.Color.background
        font = Theme.TextField.Font.default
        layer.cornerRadius = 12
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 16
        layer.shadowColor = Theme.TextField.Color.shadow.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    
    // MARK: - Text Area
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
}
