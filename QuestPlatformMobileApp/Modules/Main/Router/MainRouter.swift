//
//  MainRouter.swift
//  QuestPlatformMobileApp
//
//  Created by Anton Poltoratskyi on 08.03.2018.
//  Copyright © 2018 Anton Poltoratskyi. All rights reserved.
//

import UIKit

protocol MainRouterInput: class {
}

final class MainRouter: Router, MainRouterInput {
    
    weak var viewController: UIViewController!
}