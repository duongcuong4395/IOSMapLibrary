//
//  MarkerViewModel.swift
//  SinTraffic
//
//  Created by pc on 07/01/2024.
//

import Foundation
import GoogleMaps
import SwiftUI
import UIKit

protocol MarkerVMEvent {
    func createMarker<T: MarKerData>(with data: T) -> GMSMarker
    func getIndexMarker(for data: MarKerData) -> Int
    func checkExistsMarkerActive(complete: ([GMSMarker]) -> Void)
    func updateIconMarker(for data: MarKerData)
    func toggleArrowMarkers(with showArrow: Bool, for mapView: GMSMapView)
    func checkMarkerActive(at mk: GMSMarker, complete: @escaping (Bool) -> Void)
    func activeMarker(at marker: GMSMarker, complete: @escaping () -> Void)
}

class MarkerViewModel: ObservableObject {
    @Published var markers: [GMSMarker] = []
    
    @Published var markerSelected: GMSMarker? = GMSMarker()
    
    init() {}
}

extension MarkerViewModel: MarkerVMEvent {
    @MainActor
    func createMarker<T: MarKerData>(with data: T) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = data.getPosition()
        //marker.infoWindowAnchor = CGPoint(x: 0, y: 0)
    
        marker.userData = data
        marker.title = data.getTitle()
        marker.snippet = data.getSnippet()
        marker.icon = data.renderIcon()
        marker.groundAnchor = data.getAnchor(bounds: data.getBoundMarker())
        marker.rotation = data.getRotationIcon()
        marker.zIndex = 1
        //marker.isDraggable = true
        self.markers.append(marker)
        
        return marker
    }

    func getIndexMarker(for data: MarKerData) -> Int {
        return markers.firstIndex { marker in
            if let dt = marker.userData as? MarKerData {
                return dt.getTitle() == data.getTitle() && dt.getIconType() == data.getIconType()
            }
            else {
                return false
            }
       } ?? -1
    }
    
    func checkExistsMarkerActive(complete: ([GMSMarker]) -> Void) {
        
        var mks: [GMSMarker] = []
        var count = 0
        markers.forEach { marker in
            if let data = marker.userData as? MarKerData {
                if data.getActive() == true {
                    mks.append(marker)
                }
            }
            count += 1
            if count == markers.count {
                complete(mks)
            }
        }
    }
    
    @MainActor 
    func updateIconMarker(for data: MarKerData) {
        let index = getIndexMarker(for: data)
        guard index > -1 else { return }
        
        markers[index].iconView = data.getIcon()
        markers[index].userData = data
    }

    
    func toggleArrowMarkers(with showArrow: Bool, for mapView: GMSMapView) {
        markers.forEach { marker in
            if let data = marker.userData as? MarKerData {
                if data.getIconType() == .ARROW {
                    marker.rotation = data.getRotationIcon()
                    marker.map = showArrow ? mapView : nil
                }
            }
        }
    }
    
    func updateArrowRotateMarkers(with newAngle: CLLocationDegrees, by iconType: MarkerIconType) {
        markers.forEach { marker in
            if let data = marker.userData as? MarKerData {
                if data.getIconType() == iconType {
                    let angle = data.getRotationIcon() - newAngle
                    marker.rotation = angle//data.getRotationIcon()
                    
                }
            }
        }
    }
    
    
    
    // MARK: Markers Active
    func checkMarkerActive(at mk: GMSMarker, complete: @escaping (Bool) -> Void) {
        if let index = markers.firstIndex(where: { marker in
            marker.title == mk.title
        }) {
            if let data = markers[index].userData as? MarKerData {
                complete(data.getActive())
            }
        }
    }
    
    @MainActor 
    func activeMarker(at marker: GMSMarker, complete: @escaping () -> Void) {
        guard var data = marker.userData as? MarKerData else { complete(); return }
        
        data.toggleActive()
        updateIconMarker(for: data)
    }
}

// MARK: - Fiind Marker
extension MarkerViewModel {
    func get(by name: String) -> MarKerData? {
        let marker = markers.first{ $0.title == name }
        guard let marker = marker else { return nil }
        guard let markerDT = marker .userData as? MarKerData else { return nil }
        return markerDT
    }
}

// MARK: Clear Markers
extension MarkerViewModel {
    func clearAllMarker(completion: () -> Void) {
        for marker in markers {
            marker.map = nil
        }
        markers.removeAll()
        completion()
    }
    
    func clearMarkers(by iconType: MarkerIconType, completion: () -> Void) {
        self.markers.forEach { marker in
            if let data = marker.userData as? MarKerData {
                if data.getIconType() == iconType {
                    marker.map = nil
                }
            }
        }
        
        self.markers.removeAll { mk in
            if let dt = mk.userData as? MarKerData {
                return dt.getIconType() == iconType
            } else {
                return false
            }
        }
        completion()
    }
    
    @MainActor
    func clearMarkerActive(completion: () -> Void) {
        checkExistsMarkerActive { markers in
            markers.forEach { marker in
                if var data = marker.userData as? MarKerData {
                    data.toggleActive()
                    updateIconMarker(for: data)
                }
            }
        }
        
    }
    
    func clearMarkers(with listData: [MarKerData], completion: () -> Void) {
        listData.forEach { data in
            clearMarker(at: data)
        }
        
        completion()
    }
    
    func clearMarker(at markerData: MarKerData) {
        if let index = markers.firstIndex(where: { marker in
            if let data = marker.userData as? MarKerData {
                return data.getIconType() == markerData.getIconType() && data.getTitle() == markerData.getTitle()
            }
            return false
        }) {
            markers[index].map = nil
            markers.remove(at: index)
        }
    }
    
    
    func setMarkerSelect(from model: MarKerData, completion: @escaping (GMSMarker?) -> Void) {
        let mk = markers.first { mk in
            guard let data = mk.userData as? MarKerData else { return false }
            guard data.getTitle() == model.getTitle() && data.getIconType() == model.getIconType() else { return false }
            return true
        }
        
        guard let mk = mk else {
            markerSelected = nil
            completion(nil)
            return }
        
        self.markerSelected = mk
        completion(self.markerSelected)
    }
}

struct InfoWindowContentView: View {
    var marKerData: MarKerData
    var mapStyle: MapStyle
    var body: some View {
        
        if marKerData.getTitle() != "" {
            marKerData.getIconType().getInforMarkerView(mapStyle: mapStyle, model: marKerData.getInforMarkerModel())
                .onTapGesture {
                    print("InfoWindowContentView.táp")
                }
        } else {
            //Text("")
            EmptyView()
        }
    }
}


class SwiftUIHostingView: UIView {
    private var hostingController: UIHostingController<AnyView>?

    func setup<Content: View>(hostedView: Content) {
        let anyView = AnyView(hostedView)
        hostingController = UIHostingController(rootView: anyView)
        hostingController?.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController!.view)
        hostingController?.view.backgroundColor = .clear
        NSLayoutConstraint.activate([
            hostingController!.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController!.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController!.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController!.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}


// MARK: For Markers
extension MapsViewModel {
    
    @MainActor
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        markerVM.markerSelected = marker
        updateMarkerInforView(at: marker)
        
        MapMange.share.send(event: .didTap(at: marker))
        return true
    }
    
    
    private func addMakerToMap(from marker: GMSMarker) {
        marker.map = mapView
    }
    
    @MainActor 
    func addMarker(from data: MarKerData) {
        let index = markerVM.getIndexMarker(for: data)
        
        guard index < 0 else {
            markerVM.markers[index].position = data.getPosition()
            return
        }
        
        let marker = markerVM.createMarker(with: data)
        addMakerToMap(from: marker)
    }
    
    @MainActor 
    func addListMarker(from objs: [MarKerData]) {
        for markerData in objs {
            addMarker(from: markerData)
        }
    }
    
    @MainActor
    func addListMarker2(from objs: [any MarKerData]) {
        for markerData in objs {
            addMarker(from: markerData)
        }
    }
    
    func viewMarkerInfor(from data: MarKerData) {
        let index = markerVM.getIndexMarker(for: data)
        guard index > -1 else { return }
        updateMarkerInforView(at: markerVM.markers[index])
    }
    
    func updateMarkerInforView(at marker: GMSMarker) {
        guard marker.title != nil else { return }
        
        MapMange.share.widthMarkerInfor = 200
        self.customView.removeFromSuperview()
        self.customView = createMarkerInfor(at: marker)
        self.customView.isUserInteractionEnabled = true
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnCustomView))
            self.customView.addGestureRecognizer(tapGesture)
        
        self.mapView.addSubview(customView)
    }
    
    @objc func handleTapOnCustomView() {
        self.customView.removeFromSuperview()
    }
    
    func createMarkerInfor(at marker: GMSMarker) -> UIView {
        let hostingView = SwiftUIHostingView()
        
        let markerData = marker.userData as! (any MarKerData)
        //let sizeView = markerData.getSizeInforMarker()
        let numbLine = markerData.getNumbLineBody()
        
        let heightInforMarker = Double(20 * numbLine) + 5
        
        let widthInforMarker = MapMange.share.widthMarkerInfor // getSizeInforMarker
        
        let infoWindowContentView = InfoWindowContentView(marKerData: markerData, mapStyle: MapMange.share.mapStyle)
        hostingView.setup(hostedView: infoWindowContentView)
        let yOffset: CGFloat = CGFloat(-1 * heightInforMarker - 25)
        let xOffset: CGFloat = CGFloat(-1 * widthInforMarker / 2)
        // Thiết lập vị trí cho info window
        let position = mapView.projection.point(for: marker.position)
        hostingView.frame = CGRect(x: position.x + xOffset, y: position.y + yOffset
                                   , width: Double(widthInforMarker)
                                   , height: heightInforMarker)
        
        return hostingView
    }
    
    func clearInforMarker() {
        MapMange.share.widthMarkerInfor = 0
        self.customView.removeFromSuperview()
    }
    
    @MainActor
    func viewOnMap(for model: MarKerData) {
        moveMapTo(lat: model.getPosition().latitude, long: model.getPosition().longitude, zoom: 17)
        self.addMarker(from: model)
        markerVM.setMarkerSelect(from: model) { mk in
            self.showMarkerInfor()
            //guard let mk = mk else { return }
            //guard let dt = mk.userData as? MarKerData else { return }
            //DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                //self.viewMarkerInfor(from: dt)
            //}
        }
        //DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //self.viewMarkerInfor(from: model)
        //}
    }
    
    func showMarkerInfor() {
        guard let mk = markerVM.markerSelected else {
            clearInforMarker()
            return }
        guard let dt = mk.userData as? MarKerData else {
            clearInforMarker()
            return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewMarkerInfor(from: dt)
        }
    }
    
    func positionCustomView(at marker: GMSMarker) {
        guard let dt = marker.userData as? MarKerData else { return }
        self.customView.removeFromSuperview()
            self.customView = createMarkerInfor(at: marker)
            self.mapView.addSubview(customView)
        /*
        guard let dt = marker.userData as? MarKerData else { return }
        let heightInforMarker = Double(20 * dt.getNumbLineBody()) + 5
        let widthInforMarker = MapMange.share.widthMarkerInfor
        
        let yOffset: CGFloat = CGFloat(-1 * heightInforMarker - 25)
        let xOffset: CGFloat = CGFloat(-1 * widthInforMarker / 2)
        
        let position = mapView.projection.point(for: marker.position)
        customView.frame.origin = CGPoint(x: position.x + xOffset, y: position.y + yOffset)
        */
    }
}
