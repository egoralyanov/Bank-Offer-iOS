//
//  DetailView.swift
//  BBank
//
//  Created by Egor on 21.01.2025.
//

import SwiftUI

struct DetailView: View {

    private let offer: Offer

    init(offer: Offer) {
        self.offer = offer
    }

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: offer.getImageUrl() ?? "")) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.gray
                        ProgressView()
                    }
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(contentMode: .fit)
                case let .failure(error):
                    Text(error.localizedDescription)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200, alignment: .center)

            Text(offer.name)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Обслуживание: \(offer.cost.description) руб./мес.")
            Text("Бонус: \(offer.bonus)")
            Text("Факт: \(offer.fact)")
            Text("Описание: \(offer.description)")

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
