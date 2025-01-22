//
//  NetworkService.swift
//  BBank
//
//  Created by Egor on 21.01.2025.
//

import Foundation

enum Method: String {
    case get = "GET"
}

struct CustomError: Error {
    let message: String
}

final class NetworkService {
    private let networkConfiguration: NetworkConfiguration

    private lazy var urlSession: URLSession = {
        URLSession(configuration: .default)
    }()

    private var dataTask: URLSessionDataTask?
    private let jsonDecoder = JSONDecoder()

    init(networkConfiguration: NetworkConfiguration) {
        self.networkConfiguration = networkConfiguration
    }

    func requestAsync<T:Decodable>(path: String, method: Method, contentType: String = "application/json", body: Data = Data()) async throws -> Result<T, Error> {
        guard let baseURL = networkConfiguration.getBaseURL(), let url = URL(string: "\(baseURL)/\(path)") else {
            return .failure(CustomError(message: "Неверный адрес"))
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = body

        do  {
            let (data, _) = try await urlSession.data(for: urlRequest)
            if let content = try? self.jsonDecoder.decode(T.self, from: data) {
                return .success(content)
            } else {
                return .failure(CustomError(message: "Пустой ответ"))
            }
        } catch {
            return .failure(CustomError(message: "Ошибка декодирования"))
        }
    }
}
