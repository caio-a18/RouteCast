//
//  RadarView.swift
//  RouteCast
//
//  Created by Sophia Kager on 4/10/26.
//
import SwiftUI
import MapKit
import Combine
import Foundation
import WebKit

struct RadarView: UIViewRepresentable {
    var latitude: Double
    var longitude: Double
    
    func makeUIView(context: Context) -> WKWebView {
        
        // 1. Create configuration + script controller
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // 2. JavaScript to remove the banner
        let js = """
        function cleanUI() {
            const selectors = [
                '.banner',
                '.menu'
            ];

            selectors.forEach(sel => {
                document.querySelectorAll(sel).forEach(el => el.remove());
            });
        }

        // Run immediately
        cleanUI();

        // Keep removing (Vue re-renders these constantly)
        const observer = new MutationObserver(cleanUI);
        observer.observe(document.documentElement, {
            childList: true,
            subtree: true
        });
        """
        
        let script = WKUserScript(
            source: js,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        
        userContentController.addUserScript(script)
        config.userContentController = userContentController
        
        // 3. Create WKWebView with config
        let webView = WKWebView(frame: .zero, configuration: config)
        
        // 4. Load URL
        let urlString = "https://radar.weather.gov/?settings=v1_eyJhZ2VuZGEiOnsiaWQiOiJ3ZWF0aGVyIiwiY2VudGVyIjpbLTgwLjcyNiw0MS45NDVdLCJsb2NhdGlvbiI6Wy0xMTMuNjQ5LDM5Ljc3Ml0sInpvb20iOjUuNTUxNTY3ODc3MDkyMDA4LCJsYXllciI6ImJyZWZfcWNkIn0sImFuaW1hdGluZyI6dHJ1ZSwiYmFzZSI6InN0YW5kYXJkIiwiYXJ0Y2MiOmZhbHNlLCJjb3VudHkiOmZhbHNlLCJjd2EiOmZhbHNlLCJyZmMiOmZhbHNlLCJzdGF0ZSI6ZmFsc2UsIm1lbnUiOnRydWUsInNob3J0RnVzZWRPbmx5IjpmYWxzZSwib3BhY2l0eSI6eyJhbGVydHMiOjAuOCwibG9jYWwiOjAuNiwibG9jYWxTdGF0aW9ucyI6MC44LCJuYXRpb25hbCI6MC42fX0%3D"
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {

    RadarView(latitude: 41.510008, longitude: -81.604189)
}
