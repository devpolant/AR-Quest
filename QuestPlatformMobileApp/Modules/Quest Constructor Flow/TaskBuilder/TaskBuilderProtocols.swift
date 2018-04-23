//
//  TaskBuilderProtocols.swift
//  QuestPlatformMobileApp
//
//  Created by Anton Poltoratskyi on 23.04.2018.
//  Copyright © 2018 Anton Poltoratskyi. All rights reserved.
//

import UIKit

// MARK: - Module Input

protocol TaskBuilderModuleInput: ModuleInput {
    var output: TaskBuilderModuleOutput? { get set }
}

protocol TaskBuilderModuleOutput: class {
    func taskBuilderModule(_ moduleInput: TaskBuilderModuleInput, didCreateTask task: Task)
}

// MARK: - View

protocol TaskBuilderViewInput: class {
}

// MARK: -
protocol TaskBuilderViewOutput: class {
}

// MARK: - Interactor

protocol TaskBuilderInteractorInput: class {
}

// MARK: -
protocol TaskBuilderInteractorOutput: class {
}

// MARK: - Router

protocol TaskBuilderRouterInput: class {
}