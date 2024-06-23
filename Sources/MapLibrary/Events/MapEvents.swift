//
//  MapEvents.swift
//  SinTraffic
//
//  Created by pc on 11/01/2024.
//

import Foundation
import GoogleMaps
import Combine





public enum MapEvent {
    case didTapAtCoordinate(CLLocationCoordinate2D)
    case didLongPressAtCoordinate(CLLocationCoordinate2D)
    case didTap(coordinate: CLLocationCoordinate2D)
    case didLongPress(coordinate: CLLocationCoordinate2D)
    case willMove(gesture: Bool)
    case didChange(position: GMSCameraPosition)
    case didEndChange(at: GMSCameraPosition)
    case mapViewDidFinishTileRendering
}

public protocol MapsEvent {
    func didTapAtCoordinate(at point: CLLocationCoordinate2D)
    func didLongPressAtCoordinate(at point: CLLocationCoordinate2D)
    func didTap(at point: CLLocationCoordinate2D)
    func didLongPress(coordinate: CLLocationCoordinate2D)
    func willMove(gesture: Bool)
    func didChange(position: GMSCameraPosition)
    func didEndChange(at: GMSCameraPosition)
    func mapViewDidFinishTileRendering()
}

extension MapsEvent {
    func didTapAtCoordinate(at point: CLLocationCoordinate2D) { return }
    func didLongPressAtCoordinate(at point: CLLocationCoordinate2D) { return }
    func didTap(at point: CLLocationCoordinate2D) { return }
    func didLongPress(coordinate: CLLocationCoordinate2D) { return }
    func willMove(gesture: Bool) { return }
    func didChange(position: GMSCameraPosition) { return }
    func didEndChange(at: GMSCameraPosition) { return }
    func mapViewDidFinishTileRendering() { return }
}


public class MapMange {
    static let share = MapMange()
    public var showTitle: Bool = false
    public var mapStyle: MapStyle = .light
    public var showArrow: Bool = false
    public var radiusScan : Double = 700
    public var mapSizeState: MapSizeState = .halfScreen
    public var mapAngle: Int = 0
    
    public var mapScanAngle: Double = 25.0
    public var widthMarkerInfor: Double = 0 // 200.0
    public var centerPoint: Point = Point(lat: 1.3167404741603153, long: 103.82397923939381)
    
    public var mapBound: (xMax: Double, xMin: Double, yMax: Double, yMin: Double) = (xMax: 1.470895, xMin: 1.153183, yMax: 104.089231, yMin: 103.606952)
    public var isOverBound: Bool = false
    public var isDrawingMap: Bool = false
    
    let notifyEventMap = PassthroughSubject<MapEvent, Never>()
    let notifyEventMarker = PassthroughSubject<MarkerEvent, Never>()
    
    let notifyMapsEvent = PassthroughSubject<MapsEvent, Never>()
    
    
    public var markerScale: CGFloat = 1.0
    public var mapBearing: CLLocationDirection = 0.0
    
    public init() {
        _ = checkOverBound()
    }
    
    public func checkOverBound() -> Bool {
        if (centerPoint.lat > mapBound.xMax
        || centerPoint.lat < mapBound.xMin
        || centerPoint.long > mapBound.yMax
            || centerPoint.long < mapBound.yMin) {
            isOverBound = true
            return true
        }
        isOverBound = false
        return false
    }
}

extension MapMange {
    func send(from mapsEvent: MapsEvent) {
        notifyMapsEvent.send(mapsEvent)
    }
    
    func send(event: MapEvent) {
        notifyEventMap.send(event)
    }
    
    func send(event: MarkerEvent) {
        notifyEventMarker.send(event)
    }
}

protocol MapEventForViewModel {
    func get<T: MarKerData>(by radius: Double, at point: CLLocation, from objs: [T], complete: @escaping ([T]) -> Void)
}

extension MapEventForViewModel {
    func get<T: MarKerData>(by radius: Double, at point: CLLocation, from objs: [T], complete: @escaping ([T]) -> Void) {
        var listObj : [T] = []
        
        if objs.count <= 0 {
            complete([])
            return
        }
        
        var count = 0
        objs.forEach { obj in
            let distance = point.distance(from: CLLocation(latitude: obj.getPosition().latitude, longitude: obj.getPosition().longitude))
            if distance <= radius {
                listObj.append(obj)
            }
            count += 1
            if count == objs.count {
                complete(listObj)
            }
        }
       
    }
}
