import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Color.green
                .ignoresSafeArea()
                .overlay {
                    Text("Top 5 Spotify Hits")
                        .foregroundColor(.black)
                        .bold()
                        .font(.system(size: 45))
                        .multilineTextAlignment(.center)
                        .padding()
                        .offset(y:-300)
                    
                    Image("Image")
                    
                    
                }
        }
    }
}//#imageLiteral(resourceName: "Unknown-1.pn
