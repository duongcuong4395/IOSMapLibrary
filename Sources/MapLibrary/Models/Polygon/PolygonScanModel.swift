//
//  PolygonScanModel.swift
//  SinTraffic
//
//  Created by pc on 15/06/2024.
//

import Foundation
import GoogleMaps

struct PolygonScanModel {
    var name: String = ""
    var path: [CLLocationCoordinate2D] = []
}

extension PolygonScanModel: PolygonData {
    func getPath() -> [CLLocationCoordinate2D] {
        return path
    }
    
    func getTitle() -> String {
        return name
    }
    
    func getStrokeWidth() -> CGFloat {
        0.0
    }
    
    func getStrokeColor() -> UIColor {
        .blue.withAlphaComponent(0.5)
    }
    
    func getTappable() -> Bool {
        false
    }
    
    
}
