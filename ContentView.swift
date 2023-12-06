import SwiftUI
import Combine
import Foundation

struct AccessToken: Decodable {
    let token: String?
    let type: String?
    let expire: Int?
    
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case type = "token_type"
        case expire = "expires_in"
    }
}

class AuthManager {
    static let shared = AuthManager()
    
    private let authKey: String
    
    private init() {
        // Replace these values with your actual client ID and client secret
        let clientID = "c79384e5c05142aba6143e5e44c5f252"
        let clientSecret = "b3980a2551ba4b2785f59f44f0c051c0"
        let rawKey = "\(clientID):\(clientSecret)"
        self.authKey = "Basic \(rawKey.base64Encoded())"
    }
    
    func getAccessToken() -> AnyPublisher<String, Error> {
        guard let url = tokenURL else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethods.post.rawValue
        
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
        return URL(string: "https://accounts.spotify.com/api/token")
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

struct ContentView: View {
    @State private var cancellables: Set<AnyCancellable> = []
    
    var body: some View {
        VStack {
            Color.black
                .ignoresSafeArea()
                .overlay(
                    VStack {
                        Button("Authorize with Spotify") {
                            initiateSpotifyAuthorization()
                        }
                        .foregroundColor(.green)
                        .font(.system(size: 20))
                        .offset(y: 350)
                        
                        Text("Spotify Top 5")
                            .foregroundColor(.green)
                            .font(.system(size: 50))
                            .offset(y: -280)
                        
                        Image("spotify")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .offset(y: -290)
                    }
                )
        }
        .onOpenURL { url in
            handleCallback(url: url)
        }
    }
    
    private func initiateSpotifyAuthorization() {
        let authorizationEndpoint = "https://accounts.spotify.com/authorize"
        
        let clientID = "c79384e5c05142aba6143e5e44c5f252"  // Replace with your actual client ID
        let redirectURI = "https://yourapp.com/callback"   // Replace with your actual redirect URI
        let responseType = "code"
        let scope = "playlist-modify-public"
        let state = UUID().uuidString
        
        var components = URLComponents(string: authorizationEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: responseType),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "state", value: state),
            // Add other parameters as needed (e.g., show_dialog)
        ]
        
        // Open the authorization URL in Safari or default browser
        if let authorizationURL = components?.url {
            UIApplication.shared.open(authorizationURL)
        }
    }
    
    private func handleCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return
        }
        
        // Now you have the authorization code, use it to obtain the access token
        exchangeCodeForAccessToken(code: code)
    }
    
    private func exchangeCodeForAccessToken(code: String) {
        AuthManager.shared.getAccessToken()
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { accessToken in
                print("Access Token: \(accessToken)")
                // Implement logic to fetch top 5 songs based on the selected genre
            })
            .store(in: &cancellables)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
