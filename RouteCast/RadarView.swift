//
//  RadarView.swift
//  RouteCast
//
//  Created by Sophia Kager on 4/10/26.
//
import SwiftUI
import Foundation
import WebKit

struct RadarView: UIViewRepresentable {
    var latitude: Double
    var longitude: Double
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        let urlString = "https://www.rainviewer.com/map.html?loc=\(latitude),\(longitude),6"
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
