//
//  BBankRemoteService.swift
//  BBank
//
//  Created by Egor on 22.01.2025.
//

import Foundation

struct OfferListRemoteModel: Decodable {
    let offers: [Offer]

    init(offers: [Offer]) {
        self.offers = offers
    }

    init() {
        self.init(offers: [])
    }
}

struct Offer: Decodable, Hashable {
    let pk: Int
    let name: String
    let description: String
    let bonus: String
    let fact: String
    let cost: Int
    let imageUrl: String?

    func getImageUrl() -> String? {
        guard let imageUrl, let ipAddress = DI.shared.networkConfiguration.ipAddress else { return nil }

        return imageUrl.replacingOccurrences(of: "127.0.0.1", with: ipAddress).replacingOccurrences(of: "localhost", with: ipAddress)
    }
}

final class BBankRemoteService {
    private weak var networkService: NetworkService?

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func loadOffersAsync() async -> Result<OfferListRemoteModel, Error> {
        do {
            return try await networkService?.requestAsync(path: "offers/", method: .get) ?? .failure(CustomError(message: "Ошибка в работе сетевого слоя"))
        } catch {
            return .failure(error)
        }
    }
}
