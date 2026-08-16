//
//  PaymobCheckoutWebView.swift
//  Payment
//
//  Created by Al-Mahir.
//

import SwiftUI
import WebKit

public struct PaymobCheckoutWebView: UIViewRepresentable {
    let clientSecret: String
    let publicKey: String
    let onComplete: (Bool) -> Void

    public init(clientSecret: String, publicKey: String, onComplete: @escaping (Bool) -> Void) {
        self.clientSecret = clientSecret
        self.publicKey = publicKey
        self.onComplete = onComplete
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        let urlString: String
        if !publicKey.isEmpty {
            urlString = "https://accept.paymob.com/unifiedcheckout/?publicKey=\(publicKey)&clientSecret=\(clientSecret)"
        } else {
            urlString = "https://accept.paymob.com/unifiedcheckout/?clientSecret=\(clientSecret)"
        }
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {}

    public final class Coordinator: NSObject, WKNavigationDelegate {
        let onComplete: (Bool) -> Void

        init(onComplete: @escaping (Bool) -> Void) {
            self.onComplete = onComplete
        }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let urlString = navigationAction.request.url?.absoluteString {
                if urlString.contains("success=true") || urlString.contains("approved") || urlString.contains("txn_response_code=0") {
                    onComplete(true)
                } else if urlString.contains("success=false") || urlString.contains("declined") {
                    onComplete(false)
                }
            }
            decisionHandler(.allow)
        }
    }
}
