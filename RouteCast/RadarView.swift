//
//  RadarView.swift
//  RouteCast
//
//  Created by Sophia Kager on 4/10/26.
//

import SwiftUI
import WebKit
import MapKit

final class Coordinator {
    var lastCoords: [CLLocationCoordinate2D] = []
}

struct RadarView: UIViewRepresentable {

    let coordinates: [CLLocationCoordinate2D]
    let title: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }


    func makeUIView(context: Context) -> WKWebView {

        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()

        let js = """
        function cleanUI() {
            const selectors = ['.banner', '.menu'];

            selectors.forEach(sel => {
                document.querySelectorAll(sel).forEach(el => el.remove());
            });
        }

        cleanUI();

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

        let webView = WKWebView(frame: .zero, configuration: config)

        context.coordinator.lastCoords = coordinates
        loadRadar(into: webView)

        return webView
    }
    
    private func loadRadar(into webView: WKWebView) {
        let url = makeRadarURL(coords: coordinates)

        let request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 30
        )

        webView.load(request)
    }
    

    func updateUIView(_ webView: WKWebView, context: Context) {

        if context.coordinator.lastCoords.map({ "\($0.latitude),\($0.longitude)" })
            == coordinates.map({ "\($0.latitude),\($0.longitude)" }) {
            return
        }

        context.coordinator.lastCoords = coordinates
        loadRadar(into: webView)
    }
    
    private func makeRadarURL(coords: [CLLocationCoordinate2D]) -> URL {
        
        let lat: Double
        let lon: Double
        let zoom: Double
        
        if coords.isEmpty {
            lat = 41.50
            lon = -81.69
            zoom = 6
        } else {
            let avgLat = coords.map(\.latitude).reduce(0, +) / Double(coords.count)
            let avgLon = coords.map(\.longitude).reduce(0, +) / Double(coords.count)
            
            lat = avgLat
            lon = avgLon
            zoom = coords.count > 3 ? 4.5 : 6
        }
        
        let json: [String: Any] = ["agenda":["id":"weather","center":[lon,lat],"location":[lon,lat],"zoom":5.466763946339284,"layer":"bref_qcd"],"animating":false,"base":"standard","artcc":false,"county":false,"cwa":false,"rfc":false,"state":false,"menu":true,"shortFusedOnly":false,"opacity":["alerts":0.8,"local":0.6,"localStations":0.8,"national":0.6]]
        
        
        let data = try! JSONSerialization.data(withJSONObject: json)
        let encoded = data.base64EncodedString()
        
        let urlString = "https://radar.weather.gov/?settings=v1_\(encoded)"
        return URL(string: urlString)!
    }
}
