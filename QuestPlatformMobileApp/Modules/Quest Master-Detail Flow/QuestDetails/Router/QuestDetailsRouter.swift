//
//  QuestDetailsRouter.swift
//  QuestPlatformMobileApp
//
//  Created by Anton Poltoratskyi on 01.04.2018.
//  Copyright © 2018 Anton Poltoratskyi. All rights reserved.
//

import UIKit

final class QuestDetailsRouter: Router, QuestDetailsRouterInput {
    
    weak var viewController: UIViewController!
    
    func join(to quest: Quest) {
        let module = QuestAssembly(quest: quest).build()
        viewController.navigationController?.pushViewController(module.view, animated: true)
    }
}
