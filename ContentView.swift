import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Authorize with Spotify") {
                // Call the function to initiate the authorization request
                initiateSpotifyAuthorization()
            }
        }
    }
    private func initiateSpotifyAuthorization() {
            let authorizationEndpoint = "https://accounts.spotify.com/authorize"
            
           
            let clientID = "Alo07"
            let redirectURI = "https://yourapp.com/callback"
            let responseType = "code"
            let scope = "playlist-modify-public"
            let state = UUID().uuidString

            
            var components = URLComponents(string: authorizationEndpoint)
            components?.queryItems = [
                URLQueryItem(name: "Alo07", value: clientID),
                URLQueryItem(name: "response_type", value: responseType),
                URLQueryItem(name: "https://yourapp.com/callback", value: redirectURI),
                URLQueryItem(name: "playlist-modify-public", value: scope),
                URLQueryItem(name: "state", value: state),
                // Add other parameters as needed (e.g., show_dialog)
            ]

            // Open the authorization URL in Safari or default browser
            if let authorizationURL = components?.url {
                UIApplication.shared.open(authorizationURL)
            }
        }
    }

    
    
    
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

