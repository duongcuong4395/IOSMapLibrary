//
//  MarkerNodePolyline.swift
//  SinTraffic
//
//  Created by pc on 11/04/2024.
//

import Foundation
import SwiftUI
import GoogleMaps

struct MarkerNodePolyline: Codable {
    var name: String = ""
    var point: Point = Point(name: "", lat: 0.0, long: 0.0, description: "")
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}

extension MarkerNodePolyline: MarKerData {
    func getPosition() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: point.lat, longitude: point.long)
    }
    
    func getTitle() -> String {
        name
    }
    
    func getIconType() -> MarkerIconType {
        .NodePolyline
    }
    
    @ViewBuilder
    func getIconView() -> AnyView {
        AnyView(getMarkerIconDefault())
    }
    
}

extension View {
    func getStyleIconMaker() -> some View {
        self.font(.caption2)
            .foregroundColor(MapMange.share.mapStyle.getIconColor().opacity(0.5))
    }
}
