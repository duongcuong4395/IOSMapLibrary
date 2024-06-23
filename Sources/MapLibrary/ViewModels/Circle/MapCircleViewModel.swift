//
//  MapCircleViewModel.swift
//  SinTraffic
//
//  Created by pc on 23/01/2024.
//

import Foundation
import GoogleMaps
import SwiftUI

enum MapCircleType {
    case loadRadius
}

protocol CircleData{
    func getTitle() -> String
    func getFillColor() -> UIColor
    func getStrokeColor() -> UIColor
    func getStrokeWidth() -> CGFloat
    func getCenterPoint() -> Point
    func getRadius() -> CGFloat //CLLocationDistance
    func getType() -> MapCircleType
}

struct ObjDevice {
    var name: String
    var point: Point
    
}

extension ObjDevice: MarKerData {
    func getPosition() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: point.lat, longitude: point.long)
    }
    
    func getTitle() -> String {
        ""
    }
    
    func getSnippet() -> String {
        ""
    }
    
    func getIconType() -> MarkerIconType {
        .USER // .DEVICE
    }
    
    func getNumbLineBody() -> Int {
        0
    }
    
    func showCenter() -> Bool {
        return true
    }
    
    mutating func updateMarkerData(with model: Any) {
        return
    }
    
    func getActive() -> Bool {
        false
    }
    
    mutating func toggleActive() {
        return
    }
    
    //func getRotationIcon() -> CLLocationDegrees {}
    
}

struct ObjsScan {
    var name: String
    var centerPoint: Point
    var radius: CGFloat = 500
}

extension ObjsScan: CircleData {
    
    
    func getFillColor() -> UIColor {
        .orange.withAlphaComponent(0.1)
    }
    
    func getStrokeColor() -> UIColor {
        .blue.withAlphaComponent(0.0)
    }
    
    func getStrokeWidth() -> CGFloat {
        0
    }
    
    func getCenterPoint() -> Point {
        centerPoint
    }
    
    func getRadius() -> CGFloat {
        radius
    }
    
    func getType() -> MapCircleType {
        .loadRadius
    }
    
    func getCirclePoints(center: Point, radius: CGFloat) -> (north: Point, east: Point, south: Point, west: Point) {
        let earthRadius: Double = 6378137 // Earth's radius in meters
        let lat = center.lat * Double.pi / 180 // Convert latitude to radians
        _ = center.long * Double.pi / 180 // Convert longitude to radians

        // Calculate the North, East, South, and West points
        let north = Point(lat: center.lat + (Double(radius) / earthRadius) * (180 / Double.pi),
                          long: center.long)
        
        let east = Point(lat: center.lat,
                         long: center.long + (Double(radius) / earthRadius) * (180 / Double.pi) / cos(lat))
        
        let south = Point(lat: center.lat - (Double(radius) / earthRadius) * (180 / Double.pi),
                          long: center.long)
        
        let west = Point(lat: center.lat,
                         long: center.long - (Double(radius) / earthRadius) * (180 / Double.pi) / cos(lat))

        return (north, east, south, west)
    }
    
    func calculateMidpoint(point1: Point, point2: Point) -> Point {
        let lat1 = point1.lat * Double.pi / 180
        let long1 = point1.long * Double.pi / 180
        let lat2 = point2.lat * Double.pi / 180
        let long2 = point2.long * Double.pi / 180

        let dLon = long2 - long1

        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)

        let latMid = atan2(sin(lat1) + sin(lat2), sqrt(pow(cos(lat1) + x, 2) + pow(y, 2)))
        let longMid = long1 + atan2(y, cos(lat1) + x)

        let midPoint = Point(lat: latMid * 180 / Double.pi, long: longMid * 180 / Double.pi)
        return midPoint
    }
    
    func calculatePointC(pointA: Point, pointB: Point, distance: Double) -> Point {
        let lat1 = pointA.lat * Double.pi / 180
        let long1 = pointA.long * Double.pi / 180
        let lat2 = pointB.lat * Double.pi / 180
        let long2 = pointB.long * Double.pi / 180

        let d = distance / 6371000 // Earth's radius in meters

        let latC = (lat1 + lat2) / 2 + d * (lat2 - lat1) / (2 * sin(d))
        let longC = (long1 + long2) / 2 + d * (long2 - long1) / (2 * sin(d))

        let pointC = Point(lat: latC * 180 / Double.pi, long: longC * 180 / Double.pi)
        return pointC
    }
}

extension ObjsScan: MarKerData {
    func getPosition() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: centerPoint.lat, longitude: centerPoint.long)
    }
    
    func getSnippet() -> String {
        ""
    }
    
    func getTitle() -> String {
        return ""
    }
    
    func getIconType() -> MarkerIconType {
        .SCAN
    }
    
    func getNumbLineBody() -> Int {
        0
    }
    
    mutating func updateMarkerData(with model: Any) {
        return
    }
    
    func getActive() -> Bool {
        false
    }
    
    mutating func toggleActive() {
        return
    }
    
    func getIconView() -> AnyView {
        AnyView(getMarkerIcon())
    }
    
    @ViewBuilder
    func getMarkerIcon() -> some View {
        ZStack {
            Text("Please move map to Singapore")
                .fontTitleMarker()
                .font(.system(size: 13, weight: .light, design: .serif))
                //.opacity(MapMange.share.showTitle ? 1 : 0)
                .padding(.bottom, 25)
                .foregroundStyleMarker()
            getIconType().getIcon()
                .foregroundStyleMarker()
                .opacity(0.8)
                .font(.caption)
        }
        .offset(y: 10)
    }
}

class MapCircleViewModel: ObservableObject {
    @Published var circles: [GMSCircle] = []    
}

extension MapCircleViewModel {
    func createCircle<T: CircleData>(by data: T) -> GMSCircle {
        let coordinate = CLLocationCoordinate2D(latitude: data.getCenterPoint().lat, longitude: data.getCenterPoint().long)
        let circle = GMSCircle(position: coordinate, radius: data.getRadius())
        circle.fillColor = data.getFillColor()
        circle.strokeWidth = data.getStrokeWidth()
        circle.strokeColor = data.getStrokeColor()
        circle.title = data.getTitle()
        
        circle.userData = data
        circle.isTappable = true
        return circle
    }
    
    func addCircle(from data: CircleData, complete: (GMSCircle?) -> Void) {
        guard circles.firstIndex(where: { circle in
            if let dt = circle.userData as? CircleData {
                return circle.title == data.getTitle() && dt.getType() == data.getType()
            } else {
                return false
            }
        }) != nil else {
            let circle = createCircle(by: data)
            circles.append(circle)
            complete(circle)
            return
        }
        complete(nil)
    }
    
    func moveCircle(from circleData: CircleData, to point: Point) {
        guard let index = circles.firstIndex(where: { circle in
            if let data = circle.userData as? CircleData {
                return data.getTitle() == circleData.getTitle() && data.getType() == circleData.getType()
            } else {
                return false
            }
        }) else { return }
        
        circles[index].position = CLLocationCoordinate2D(latitude: point.lat, longitude: point.long)
    }
    
    func checkExists(by circleData: CircleData, complete: (Bool, GMSCircle?) -> Void) {
        if let index = circles.firstIndex(where: { circle in
            if let data = circle.userData as? CircleData {
                return data.getTitle() == circleData.getTitle() && data.getType() == circleData.getType()
            } else {
                return false
            }
        }) {
            complete(true, circles[index])
            return
        } else {
            complete(false, nil)
        }
    }
    
    func clearCircle(of circleType: MapCircleType) {
        circles.forEach { circle in
            if let data = circle.userData as? CircleData {
                circle.map = data.getType() == circleType ? nil : circle.map
            }
        }
        
        circles.removeAll(where: { circle in
            if let data = circle.userData as? CircleData {
                return data.getType() == circleType
            } else {
                return false
            }
        })
    }
}
