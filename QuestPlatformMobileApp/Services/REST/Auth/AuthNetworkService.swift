//
//  AuthNetworkService.swift
//  QuestPlatformMobileApp
//
//  Created by Anton Poltoratskyi on 25.02.2018.
//  Copyright © 2018 Anton Poltoratskyi. All rights reserved.
//

import Foundation

// MARK: - Protocol

protocol AuthNetworkService: NetworkService {
    func login(with credentials: LoginCredentials, completion: @escaping (ResponseResult<User>) -> Void)
    func register(with credentials: SignUpCredentials, completion: @escaping (ResponseResult<User>) -> Void)
    func logout(completion: @escaping (ResponseResult<Bool>) -> Void)
}

// MARK: - Service

final class AuthNetworkServiceImpl: AuthNetworkService {
    
    let client: NetworkClient
    let session: SessionStorage
    
    init(client: NetworkClient, session: SessionStorage) {
        self.client = client
        self.session = session
    }
    
    func login(with credentials: LoginCredentials, completion: @escaping (ResponseResult<User>) -> Void) {
        let target = AuthNetworkRouter.login(credentials: credentials)
        client.request(to: target) { (result: ResponseResult<WebResponse<User>>) in
            completion(result.process())
        }
    }
    
    func register(with credentials: SignUpCredentials, completion: @escaping (ResponseResult<User>) -> Void) {
        let target = AuthNetworkRouter.register(credentials: credentials)
        client.request(to: target) { (result: ResponseResult<WebResponse<User>>) in
            completion(result.process())
        }
    }
    
    func logout(completion: @escaping (ResponseResult<Bool>) -> Void) {
        let target = AuthNetworkRouter.logout(token: session.token)
        client.request(to: target) { (result: ResponseResult<WebResponse<Bool>>) in
            completion(result.process())
        }
    }
}

// MARK: - Stub

final class AuthNetworkServiceStub: AuthNetworkService {
    
    let client: NetworkClient
    let session: SessionStorage
    
    init(client: NetworkClient, session: SessionStorage) {
        self.client = client
        self.session = session
    }
    
    func login(with credentials: LoginCredentials, completion: @escaping (ResponseResult<User>) -> Void) {
        let user = User(name: credentials.email, email: credentials.email)
        completion(.success(user))
    }
    
    func register(with credentials: SignUpCredentials, completion: @escaping (ResponseResult<User>) -> Void) {
        let user = User(name: credentials.email, email: credentials.email)
        completion(.success(user))
    }
    
    func logout(completion: @escaping (ResponseResult<Bool>) -> Void) {
        completion(.success(true))
    }
}