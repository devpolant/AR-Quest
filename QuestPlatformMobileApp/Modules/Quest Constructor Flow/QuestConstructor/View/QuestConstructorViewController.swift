//
//  QuestConstructorViewController.swift
//  QuestPlatformMobileApp
//
//  Created by Anton Poltoratskyi on 15.04.2018.
//  Copyright © 2018 Anton Poltoratskyi. All rights reserved.
//

import UIKit

final class QuestConstructorViewController: UIViewController, View {
    
    typealias Output = QuestConstructorViewOutput
    var output: Output!
    
    
    // MARK: - Views
    
    private lazy var contentView: QuestConstructorView = {
        let contentView = QuestConstructorView()
        return contentView
    }()
    
    
    // MARK: - Life Cycle
    
    override func loadView() {
        super.loadView()
        self.view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - QuestConstructorViewInput
extension QuestConstructorViewController: QuestConstructorViewInput {
    
}
