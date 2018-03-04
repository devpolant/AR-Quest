//
//  Theme.swift
//  QuestPlatformMobileApp
//
//  Created by Anton Poltoratskyi on 25.02.2018.
//  Copyright © 2018 Anton Poltoratskyi. All rights reserved.
//

import UIKit

enum Theme {
    enum Button {
        enum Color {
            static let title = UIColor.white
            static let lightBlue = UIColor(r: 58, g: 204, b: 225)
            static let darkGray = UIColor(r: 53, g: 58, b: 80)
        }
        enum Font {
            static let `default` = UIFont.systemFont(ofSize: 15, weight: .regular)
        }
    }
    enum TextField {
        enum Color {
            static let text = UIColor.black
            static let placeholder = UIColor(r: 120, g: 132, b: 158)
            static let background = UIColor.white
            static let shadow = UIColor(r: 69, g: 91, b: 99)
        }
        enum Font {
            static let `default` = UIFont.systemFont(ofSize: 15, weight: .regular)
        }
    }
    enum Label {
        enum Color {
            static let error = UIColor.red
        }
        enum Font {
            static let error = UIFont.systemFont(ofSize: 13, weight: .regular)
        }
    }
}

extension UIFont {
    static func appFont(ofSize fontSize: CGFloat, weight: Weight) -> UIFont {
        return systemFont(ofSize: fontSize, weight: weight)
    }
}

