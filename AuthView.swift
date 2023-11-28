//
//  AuthView.swift
//  SpotifyAPIapp
//
//  Created by Andres E. Lopez on 11/21/23.
//

import Foundation
import SwiftUI
import WebKit

struct SpotifyLoginView: UIViewRepresentable {
    let url: URL
    let onRedirect: (URL) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: SpotifyLoginView

        init(parent: SpotifyLoginView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url, url.host == "https://yourapp.com/callback" {
                // Handle the redirect URI
                parent.onRedirect(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}
