import Foundation
import Combine

class APIClient {
    private let baseURL = "http://localhost:3000/api"
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    func processIntent(message: String, walletAddress: String) -> AnyPublisher<TransactionPackage, Error> {
        guard let url = URL(string: "\(baseURL)/process-intent") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // Create request body
        let body: [String: Any] = [
            "message": message,
            "walletAddress": walletAddress
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            return Fail(error: APIError.encodingError).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.requestFailed
                }
                return data
            }
            .decode(type: TransactionPackage.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func fetchContractABI(contractAddress: String) -> AnyPublisher<[String: Any], Error> {
        guard let url = URL(string: "\(baseURL)/abi/\(contractAddress)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.requestFailed
                }
                return data
            }
            .tryMap { data in
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let abi = json["abi"] as? [String: Any] else {
                    throw APIError.decodingError
                }
                return abi
            }
            .eraseToAnyPublisher()
    }
}

enum APIError: Error {
    case invalidURL
    case requestFailed
    case encodingError
    case decodingError
    case networkError
} 