//
//  NetworkConfiguration.swift
//  BBank
//
//  Created by Egor on 21.01.2025.
//

import SwiftUI

final class NetworkConfiguration {
    @AppStorage("ipAddress") var ipAddress: String?

    func getBaseURL() -> String? {
        guard let ipAddress else { return nil }

        return "http://\(ipAddress):8000"
    }
}
