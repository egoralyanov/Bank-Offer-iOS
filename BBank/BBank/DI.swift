//
//  DI.swift
//  BBank
//
//  Created by Egor on 22.01.2025.
//

import Foundation

class DI {
    static let shared = DI()

    lazy var networkConfiguration: NetworkConfiguration = {
        NetworkConfiguration()
    }()

    lazy var networkService: NetworkService = {
        NetworkService(networkConfiguration: networkConfiguration)
    }()

    lazy var bbankRemoteService: BBankRemoteService = {
        BBankRemoteService(networkService: networkService)
    }()
}
