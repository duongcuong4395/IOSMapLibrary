//
//  MarKerData.swift
//  SinTraffic
//
//  Created by pc on 16/01/2024.
//

import Foundation
import GoogleMaps
import SwiftUI

protocol MarKerData {
    
    func getPosition() -> CLLocationCoordinate2D
    func getTitle() -> String
    func getSnippet() -> String
    
    func getIcon() -> UIView
    func getIconView() -> AnyView
    func getBoundMarker() -> CGRect
    func getIconType() -> MarkerIconType
    func getRotationIcon() -> CLLocationDegrees
    func getPoint() -> CGPoint
    
    
    //func getSizeInforMarker() -> Double
    func getNumbLineBody() -> Int
    func getInforMarkerModel() -> Decodable
    
    mutating func updateMarkerData(with model: Any)
    func getActive() -> Bool
    mutating func toggleActive()
    
    func getNode() async throws -> Node
    
    func showCenter() -> Bool
    func getAnchor(bounds: CGRect) -> CGPoint
}

extension MarKerData {
    
    func getNode() async throws -> Node {
        
        
        let traffic: TrafficItemsEmum
        
        switch getIconType() {
        case .BUSSTOP:
            traffic = .BUSSTOP
        case .BUS:
            traffic = .BUSSTOP
        case .CARPARK:
            traffic = .CARPARK
        case .TAXI:
            traffic = .TAXI
        case .BICYCLE_PARKING:
            traffic = .BICYCLE_PARKING
        case .CAMERA:
            traffic = .CAMERA
        case .ACCIDENT:
            traffic = .INCIDENT
        case .Train:
            traffic = .TRAIN
        case .INCIDENT:
            traffic = .INCIDENT
        case .ARROW:
            traffic = .ARROW
        case .SCAN, .USER, .NodePolyline:
            traffic = .TRAIN
        case .DEVICE:
            traffic = .TRAIN
        case .CENTERMAP:
            traffic = .TRAIN
        case .WEATHER:
            traffic = .TRAIN
        case .HUMIDITY:
            traffic = .TRAIN
        case .WINDDIRECTION:
            traffic = .TRAIN
        case .BusAndTrain:
            traffic = .BusAndTrain
        }
        
        let node = Node(name: getTitle(),coordinate: Coordinate(x: getPosition().latitude, y: getPosition().longitude), typeTraffic: traffic)
        
        guard getIconType() == .BUSSTOP || getIconType() == .Train else { return node }
        //guard  else { return node }
        
        let newNode = try await node.pushToFireBase(by: ["name" : node.name])
        
        return newNode ?? node
    }
    
    
    func getIconView() -> AnyView {
        AnyView(getMarkerIcon())
    }
    
    @ViewBuilder
    private func getMarkerIcon() -> some View {
        ZStack {
            if MapMange.share.showTitle {
                Text(getTitle())
                    .fontTitleMarker()
                    .opacity(MapMange.share.showTitle ? 1 : 0)
                    .padding(.bottom, 25)
                    .foregroundStyleMarker()
            }
            
            getIconType().getIcon()
                .foregroundStyleMarker()
                .opacity(0.8)
                .font(.caption)
        }
        .offset(y: MapMange.share.showTitle ? 10 : 0)
        .background(.clear)
    }
    
    @ViewBuilder
    func getMarkerIconDefault() -> some View {
        ZStack {
            getIconType().getIcon()
                .getStyleIconMaker()
        }
    }
    
    func getNumbLineBody() -> Int {
        0
    }
    
    
    func getInforMarkerModel() -> Decodable {
        return self as! Decodable
    }
    
    func getActive() -> Bool {
        false
    }
    
    mutating func toggleActive() {
        return
    }
    
    func getBoundMarker() -> CGRect {
        CGRect(x: 0, y: 0, width: 70, height: 50)
    }
    
    func getPoint() -> CGPoint {
        CGPoint(x: 0, y: 0)
    }
    
    mutating func updateMarkerData(with model: Any) {
        return
    }
    
    func getTitle() -> String {
        ""
    }
    
    func getSnippet() -> String {
        ""
    }
    
    @MainActor
    func renderIcon() -> UIImage? {
        let renderer = ImageRenderer(content: getIconView())
        //renderer.uiImage?.withTintColor(.blue)
        return renderer.uiImage?.scaled(to: MapMange.share.markerScale)
    }
    
    func getIcon() -> UIView {
        let hostingController = UIHostingController(rootView: getIconView())
        hostingController.view.bounds = getBoundMarker()
        hostingController.view.layer.cornerRadius = 8.0
        hostingController.view.layer.masksToBounds = true
        hostingController.view.layer.position = getPoint()
        //hostingController.view.backgroundColor = .clear
        return hostingController.view
    }
    
    func showCenter() -> Bool {
        return false
    }
    
    func getAnchor(bounds: CGRect) -> CGPoint {
        if showCenter() {
            return CGPoint(x: 0.5, y: 0.5)
            //CGPoint(x: bounds.midX / bounds.width, y: bounds.midY / bounds.height)
        } else {
            return CGPoint(x: 0.5, y: 1)
        }
    }
}

extension MarKerData {
    func getRotationIcon() -> CLLocationDegrees {
        let start = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let end = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        return GMSGeometryHeading(start , end)
    }
}


