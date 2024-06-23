//
//  PolygonViewModel.swift
//  SinTraffic
//
//  Created by pc on 15/06/2024.
//

import Foundation
import SwiftUI
import GoogleMaps

protocol PolygonData {
    func getPath() -> [CLLocationCoordinate2D]
    func getTitle() -> String
    func getStrokeWidth() -> CGFloat
    func getStrokeColor() -> UIColor
    func getTappable() -> Bool
}

class PolygonViewModel: ObservableObject {
    @Published var polygons: [GMSPolygon] = []
    
    
}

// MARK: - For Create

extension PolygonViewModel {
    @MainActor func addPolygon<T: PolygonData>(from data: T) -> GMSPolygon {
        let polylineExists = polygons.filter { polyline in
            polyline.title == data.getTitle()
        }
        if polylineExists.count <= 0 {
            let polyline = createPolygon(from: data)
            polygons.append(polyline)
            return polyline
        } else {
            let newPath = data.getPath()
            
            let path = GMSMutablePath()
            path.add(newPath[0])
            path.add(newPath[1])
            path.add(newPath[2])
            path.add(newPath[3])
            
            polylineExists[0].path = path
        }
        return polylineExists[0]
    }
    
    
    
    @MainActor func createPolygon<T: PolygonData>(from data: T) -> GMSPolygon {
        let polygonPath = GMSMutablePath()
        
        let path = data.getPath()
        
        for point in path {
            polygonPath.add(point)
        }
        let polygon = GMSPolygon(path: polygonPath)
        polygon.title = data.getTitle()
        polygon.strokeWidth = data.getStrokeWidth()
        polygon.strokeColor = data.getStrokeColor()
        polygon.userData = data
        polygon.isTappable = data.getTappable() // Cho phép sự kiện tap
        return polygon
    }
}

// MARK: - For clear
extension PolygonViewModel {
    func clearAllPolygon() {
        polygons.forEach { poly in
            poly.map = nil
        }
        polygons.removeAll()
    }
}
