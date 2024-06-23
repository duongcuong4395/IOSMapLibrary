//
//  MarkerArrowModel.swift
//  SinTraffic
//
//  Created by pc on 13/01/2024.
//

import Foundation
import GoogleMaps
import CoreLocation
import SwiftUI


public struct MarkerArrowModel: Decodable {
    public var title: String = ""
    public var snippet: String = ""
    public var lat: Double = 0.0
    public var long: Double = 0.0
    public var startCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    public var endCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    public var nodeBefore: (lat: Double, long: Double) = (lat: 0.0, long: 0.0)
    public var isMarkerActive: Bool = false
    
    
    
    public enum CodingKeys: String, CodingKey {
        case title
        case snippet
        case lat
        case long
        case isMarkerActive
      }
}

extension MarkerArrowModel: MarKerData {
    @ViewBuilder
    func getIconView() -> AnyView {
        AnyView(getMarkerIconDefault())
    }
    
    func getActive() -> Bool {
        return isMarkerActive
    }
    
    mutating func toggleActive() {
        self.isMarkerActive = !isMarkerActive
    }
    
    func getPosition() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getSnippet() -> String {
        return "\(nodeBefore.lat),\(nodeBefore.long)"
    }
    
    func getIconType() -> MarkerIconType {
        .ARROW
    }
    
    func getRotationIcon() -> CLLocationDegrees {
        return GMSGeometryHeading(startCoordinate, endCoordinate)// - MapMange.share.mapBearing
    }
    
}

struct MarkerScanModel {
    public var title: String = ""
    public var snippet: String = ""
    public var lat: Double = 0.0
    public var long: Double = 0.0
    var isMarkerActive = false
}

extension MarkerScanModel: MarKerData {
    @ViewBuilder
    func getIconView() -> AnyView {
        AnyView(ScanIconMarker(model: self))
    }
    
    func getActive() -> Bool {
        return isMarkerActive
    }
    
    mutating func toggleActive() {
        self.isMarkerActive = !isMarkerActive
    }
    
    func getPosition() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getSnippet() -> String {
        return snippet
    }
    
    func getIconType() -> MarkerIconType {
        .SCAN
    }
    
    func getRotationIcon() -> CLLocationDegrees {
        return GMSGeometryHeading(CLLocationCoordinate2D(), CLLocationCoordinate2D())
    }
    
    func getBoundMarker() -> CGRect {
        CGRect(x: 0, y: 0, width: 250, height: 250)
    }
    
    func getPoint() -> CGPoint {
        CGPoint(x: 0, y: 50)
    }
}

struct ScanIconMarker: View {
    //@EnvironmentObject var markerVM: MarkerViewModel
    var model : MarkerScanModel
    
    var body: some View {
        ZStack {
            Image(systemName: "circle.dotted")
                .font(.caption2)
                .foregroundColor(MapMange.share.mapStyle.getIconColor().opacity(0.5))
            StunningLoadingView()
        }
    }
}


struct StunningLoadingView: View {
    @State var animation: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.black.opacity(animation ? 0.0 : 1), style: StrokeStyle(lineWidth: animation ? 0.0 : 10))
                .scaleEffect(animation ? 1.0 : 0)
        }
        .frame(width: 100, height: 100)
        .onAppear{
            withAnimation(Animation.easeOut(duration: 3).repeatForever(autoreverses: false)) {
                animation.toggle()
            }
        }
    }
}
