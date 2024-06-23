//
//  PolylineViewModel.swift
//  SinTraffic
//
//  Created by pc on 13/01/2024.
//

import Foundation
import GoogleMaps
import UIKit

enum polylineType: String {
    case LineBus
    case LineTrain
    case LineBusAndTrain
}

protocol PolylineData {
    func getTitle() -> String
    //func getPath() -> [CLLocationCoordinate2D]
    func getPath() async -> [CLLocationCoordinate2D]
    func getStrokeWidth() -> CGFloat
    func getStrokeColor() -> UIColor
    func getTappable() -> Bool // Cho phép sự kiện tap vao polyline
    func getType() -> TrafficItemsEmum
}

class PolylineViewModel: ObservableObject {
    @Published var polylines: [GMSPolyline] = []
    
    @MainActor func addPolyline<T: PolylineData>(from data: T) async -> GMSPolyline {
        let polylineExists = polylines.filter { polyline in
            polyline.title == data.getTitle()
        }
        if polylineExists.count <= 0 {
            let polyline = await createPolyline(from: data)
            polylines.append(polyline)
            return polyline
        }
        return polylineExists[0]
    }
    
    @MainActor func createPolyline<T: PolylineData>(from data: T) async -> GMSPolyline {
        let polylinePath = GMSMutablePath()
        
        let path = await data.getPath()
        
        for point in path {
            polylinePath.add(point)
        }
        let polyline = GMSPolyline(path: polylinePath)
        polyline.title = data.getTitle()
        polyline.strokeWidth = data.getStrokeWidth()
        polyline.strokeColor = data.getStrokeColor()
        polyline.userData = data
        polyline.isTappable = data.getTappable() // Cho phép sự kiện tap
        return polyline
    }
    
    func highLightPolyline(by name: String) {
        
        if let index = polylines.firstIndex(where: { polyline in
            return polyline.title == name
        }) {
            polylines[index].strokeWidth = 2
        }
    }
    
    func clearAllHightlight() {
        polylines.forEach { polyline in
            polyline.strokeWidth = 1
        }
    }
    
    func getPolyline(by name: String, complete: (GMSPolyline) -> Void) {
        
        if let index = polylines.firstIndex(where: { polyline in
            return polyline.title == name
        }) {
            complete(polylines[index])
        }
    }
    
    func edit(at indexPolyline: Int, by newPath: GMSPath?) {
        polylines[indexPolyline].path = newPath
    }
}


extension PolylineViewModel {
    /*
    private func updateHeading(heading: CLHeading) {

        // Add marker for user's location
        let marker = GMSMarker()
        marker.position = location.coordinate
        marker.map = mapView
        marker.rotation = heading.trueHeading
        
        // Calculate points for the scan area
        let startAngle = heading.trueHeading - 15
        let endAngle = heading.trueHeading + 15
        let distance = 500.0 // 500 meters

        let startPoint = location.coordinate.coordinate(with: startAngle, distance: distance)
        let endPoint = location.coordinate.coordinate(with: endAngle, distance: distance)
        
        // Create the path for the scan area
        let path = GMSMutablePath()
        path.add(location.coordinate)
        path.add(startPoint)
        path.add(endPoint)
        path.add(location.coordinate) // Close the polygon

        // Create the polygon and add it to the map
        let polygon = GMSPolygon(path: path)
        polygon.fillColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2) // Semi-transparent green
        polygon.strokeColor = .green
        polygon.strokeWidth = 2
        polygon.map = mapView
    }
    */
}

// MARK: - Clear Events
extension PolylineViewModel {
    func clearAllPolyline() {
        polylines.forEach { poly in
            poly.map = nil
        }
        polylines.removeAll()
    }
    
    func clearPolyline(at data: PolylineData) {
        if let index = polylines.firstIndex(where: { polyline in
            polyline.title == data.getTitle()
        }) {
            polylines[index].map = nil
            polylines.remove(at: index)
        }
    }
}

extension PolylineViewModel {
    //func addNode(from )
}
