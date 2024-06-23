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

public extension MapsEvent {
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
    var showTitle: Bool = false
    var mapStyle: MapStyle = .light
    var showArrow: Bool = false
    var radiusScan : Double = 700
    var mapSizeState: MapSizeState = .halfScreen
    var mapAngle: Int = 0
    
    var mapScanAngle: Double = 25.0
    var widthMarkerInfor: Double = 0 // 200.0
    var centerPoint: Point = Point(lat: 1.3167404741603153, long: 103.82397923939381)
    
    var mapBound: (xMax: Double, xMin: Double, yMax: Double, yMin: Double) = (xMax: 1.470895, xMin: 1.153183, yMax: 104.089231, yMin: 103.606952)
    var isOverBound: Bool = false
    var isDrawingMap: Bool = false
    
    let notifyEventMap = PassthroughSubject<MapEvent, Never>()
    let notifyEventMarker = PassthroughSubject<MarkerEvent, Never>()
    
    let notifyMapsEvent = PassthroughSubject<MapsEvent, Never>()
    
    
    var markerScale: CGFloat = 1.0
    var mapBearing: CLLocationDirection = 0.0
    
    init() {
        _ = checkOverBound()
    }
    func checkOverBound() -> Bool {
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

public extension MapMange {
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

public protocol MapEventForViewModel {
    func get<T: MarKerData>(by radius: Double, at point: CLLocation, from objs: [T], complete: @escaping ([T]) -> Void)
}

public extension MapEventForViewModel {
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
