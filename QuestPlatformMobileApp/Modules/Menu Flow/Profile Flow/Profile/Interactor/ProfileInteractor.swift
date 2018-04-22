//
//  ProfileInteractor.swift
//  QuestPlatformMobileApp
//
//  Created by Anton Poltoratskyi on 09.04.2018.
//  Copyright © 2018 Anton Poltoratskyi. All rights reserved.
//

import Foundation

final class ProfileInteractor: Interactor, ProfileInteractorInput {
    typealias Output = ProfileInteractorOutput
    weak var output: ProfileInteractorOutput!
    
    // MARK: - Dependencies
    
    private let userService: UserNetworkService
    
    
    // MARK: - Init
    
    init(userService: UserNetworkService) {
        self.userService = userService
    }
    
    
    // MARK: - Actions
    
    func fetchUserInfo() {
        guard let user = userService.session.user else {
            return
        }
        output.didFetchUser(user)
    }
    
    func editUser(_ user: User) {
        userService.editUser(user) { [weak self] result in
            switch result {
            case let .success(user):
                self?.output?.didEditUser(user)
            case let .failure(error):
                self?.output?.didReceiveFailure(error)
            }
        }
    }
}