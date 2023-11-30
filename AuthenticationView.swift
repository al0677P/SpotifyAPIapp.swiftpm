//
//  AuthenticationView.swift
//  SpotifyAPIapp
//
//  Created by Andres E. Lopez on 11/30/23.
//

import Foundation
import Combine

class AuthManager {
    
    static let shared = AuthManager()
    
    private let authKey: String
    
    private init() {
        // Replace these values with your actual client ID and client secret
        let clientID = "YOUR_CLIENT_ID"
        let clientSecret = "YOUR_CLIENT_SECRET"
        let rawKey = "\(clientID):\(clientSecret)"
        self.authKey = "Basic \(rawKey.base64Encoded())"
    }
    
    func getAccessToken() -> AnyPublisher<String, Error> {
        guard let url = tokenURL else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethods.post.rawValue // Ensure you have this enum defined
        
        urlRequest.allHTTPHeaderFields = [
            "Authorization": authKey,
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        var requestBody = URLComponents()
        requestBody.queryItems = [URLQueryItem(name: "grant_type", value: "client_credentials")]
        urlRequest.httpBody = requestBody.query?.data(using: .utf8)
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: AccessToken.self, decoder: JSONDecoder())
            .map { accessToken -> String in
                guard let token = accessToken.token else {
                    print("The access token is not fetched.")
                    return ""
                }
                return token
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private var tokenURL: URL? {
        // Replace this URL with your actual token URL
        return URL(string: "YOUR_TOKEN_URL")
    }
}

extension String {
    func base64Encoded() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

enum HTTPMethods: String {
    case get = "GET"
    case post = "POST"
    // Add other methods as needed
}
