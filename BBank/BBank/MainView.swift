//
//  MainView.swift
//  BBank
//
//  Created by Egor on 21.01.2025.
//

import SwiftUI

struct MainView: View {
    private let remoteService = DI.shared.bbankRemoteService
    private let networkConfiguration = DI.shared.networkConfiguration

    @State private var ipAddress = ""
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var isError = false
    @State private var presentAlert = false
    @State private var offers: [Offer] = []
    @State private var filteredOffers: [Offer] = []
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            listView()
                .navigationTitle("Услуги BBank")
        }
        .task {
            await loadOffers()
        }
        .onChange(of: searchText) {
            applyFilter()
        }
        .onChange(of: offers) {
            applyFilter()
        }
        .alert("Настройки", isPresented: $presentAlert, actions: {
            TextField("Введите ip адрес", text: $ipAddress)
                .keyboardType(.decimalPad)
                .onChange(of: ipAddress) { _, newValue in
                    ipAddress = formatAsIPAddress(newValue)
                }

            Button("Сохранить") {
                networkConfiguration.ipAddress = ipAddress
                ipAddress = ""
                presentAlert = false
            }
            Button("Отменить", role: .cancel, action: { presentAlert = false })
        }, message: {
            Text("Текущий ip адрес: \(networkConfiguration.ipAddress ?? "не указан")")
        })
    }

    @ViewBuilder
    private func listView() -> some View {
        List {
            ForEach(filteredOffers, id: \.pk) { offer in
                listViewCell(offer: offer)
            }
        }
        .refreshable {
            await loadOffers()
        }
        .searchable(text: $searchText)
        .navigationDestination(for: Offer.self) { offer in
            DetailView(offer: offer)
        }
        .overlay {
            if offers.isEmpty, !searchText.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else if isLoading {
                ProgressView("Загрузка")
            } else if offers.isEmpty, isError {
                ContentUnavailableView {
                    Label("Ошибка", systemImage: "wifi.exclamationmark")
                } description: {
                    Text("Не удалось подключиться к серверу.")
                } actions: {
                    Button {
                        presentAlert = true
                    } label: {
                        Label("Проверьте настройки подключения", systemImage: "gear")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func listViewCell(offer: Offer) -> some View {
        Button {
            path.append(offer)
        } label: {
            HStack {
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
                    case let .failure(error):
                        Text(error.localizedDescription)
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(0.0)
                .clipped()
                .frame(width: 55, height: 50, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(offer.name)
            }
        }
    }

    private func loadOffers() async {
        let result = await remoteService.loadOffersAsync()
        switch result {
        case let .success(data):
            offers = data.offers
        case .failure:
            isError = true
        }
        isLoading = false
    }

    private func formatAsIPAddress(_ input: String) -> String {
        let changedInput = input.replacingOccurrences(of: ",", with: ".")

        return changedInput
    }

    private func applyFilter() {
        if !searchText.isEmpty {
            filteredOffers = offers.filter { $0.name.lowercased().hasPrefix(searchText.lowercased()) }
        } else {
            filteredOffers = offers
        }
    }
}
