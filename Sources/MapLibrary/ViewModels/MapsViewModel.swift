//
//  MapsViewModel.swift
//  SinTraffic
//
//  Created by pc on 24/12/2023.
//

import Foundation
import GoogleMaps
import Combine
import SwiftUI
import Kingfisher

struct ConicalModel {
    var name: String
    var centerPoint: CLLocationCoordinate2D
    var direction: CLLocationDirection
    var angle: Double
    var radius: Double
    var strokeWidth: CGFloat = 0
}

extension ConicalModel: PolygonData {
    func getPath() -> [CLLocationCoordinate2D] {
        let startAngle = direction - angle// 15
        let endAngle = direction + angle
        
        
        let startPoint = centerPoint.coordinate(with: startAngle, distance: radius)
        let endPoint = centerPoint.coordinate(with: endAngle, distance: radius)

        return [centerPoint, startPoint, endPoint, centerPoint]
    }
    
    func getTitle() -> String {
        name
    }
    
    func getStrokeWidth() -> CGFloat {
        strokeWidth
    }
    
    func getStrokeColor() -> UIColor {
        .blue
    }
    
    func getTappable() -> Bool {
        false
    }
    
    
}



class MapsViewModel: NSObject, ObservableObject, GMSMapViewDelegate {
    
    @Published var mapView: GMSMapView
    @Published var customView = UIView()
    @Published var centerpoint: CLLocation  = CLLocation(latitude: 1.3167404741603153, longitude: 103.82397923939381)
    
    
    @Published var markerVM: MarkerViewModel = MarkerViewModel()
    @Published var polylineVM: PolylineViewModel = PolylineViewModel()
    @Published var circleVM: MapCircleViewModel = MapCircleViewModel()
    @Published var polygonVM: PolygonViewModel = PolygonViewModel()
    
    @Published var userHeading: (Bool, CLLocationDirection) = (false, 0.0)
    private var lastHeading: CLLocationDirection?
    private var cancellables = Set<AnyCancellable>()
    
    
    //var devicederection: direction
    
    override init() {
        GMSServices.provideAPIKey(AppGen.mapKey)
        self.mapView = GMSMapView()
        super.init()
        
        mapView.mapStyle = MapMange.share.mapStyle.getURLStyle()
        self.mapView.delegate = self
        mapView.addSubview(customView)
        
        
        //self.mapView.animate(toZoom: 10)
        
    }
    
    
    
    @MainActor
    func updateMapStyle() {
        mapView.mapStyle = MapMange.share.mapStyle.getURLStyle()
        refreshIconMarker()
    }
    
    @MainActor
    func refreshIconMarker() {
        DispatchQueue.main.async { [weak self] in
            self?.markerVM.markers.forEach { marker in
                if let mkData = marker.userData as? MarKerData {
                    marker.icon = mkData.renderIcon()
                }
            }
        }
        
    }
    
    func changeMapAngle() {
        if MapMange.share.mapAngle == 0 {
            MapMange.share.mapAngle = 30
        } else if MapMange.share.mapAngle == 30 {
            MapMange.share.mapAngle = 45
        } else if MapMange.share.mapAngle == 45 {
            MapMange.share.mapAngle = 0
        }
        self.mapView.animate(toViewingAngle: Double(MapMange.share.mapAngle))
    }
}


// MARK: for Polyline
extension MapsViewModel {
    @MainActor func addPolylineOnMap(from polylineData: PolylineData) async {
        let polyline = await self.polylineVM.addPolyline(from: polylineData)
        polyline.map = self.mapView
    }
    
    @MainActor func addPolylinesOnMap(from polylineDatas: [PolylineData]) async {
        for polyline in polylineDatas {
            await addPolylineOnMap(from: polyline)
        }
    }
}

extension MapsViewModel {
    func getCenterPoint() -> CLLocation {
        return CLLocation(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
    }
}

extension MapsViewModel {
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        
        markerVM.markerSelected = nil
        clearInforMarker()
        MapMange.share.send(event: .didTapAtCoordinate(coordinate))
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        MapMange.share.send(event: .didLongPressAtCoordinate(coordinate))
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        MapMange.share.centerPoint = Point(lat: self.mapView.camera.target.latitude, long: self.mapView.camera.target.longitude)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        MapMange.share.markerScale = self.mapView.camera.zoom > 14.5 ? 1.0 : 0.7
        
        MapMange.share.centerPoint = Point(lat: position.target.latitude, long: position.target.longitude)
        
        MapMange.share.mapBearing = mapView.camera.bearing
        MapMange.share.send(event: .didChange(position: position))
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        DispatchQueue.main.async {
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.25) // Tinh chỉnh thời gian hoạt ảnh nếu cần
            
            // Cập nhật vị trí custom view khi camera thay đổi
            if let marker = self.markerVM.markerSelected {
                self.positionCustomView(at: marker)
            }
            CATransaction.commit()
            
            
        }
        MapMange.share.send(event: .didEndChange(at: position))
    }
    
}

extension MapsViewModel: MapsEvent {
    
}

extension MapsViewModel {
    func moveMapTo(lat: Double, long: Double, zoom: Float) {
        let centerCoordinate = CLLocationCoordinate2D(latitude: lat ,longitude: long)
        let camera = GMSCameraUpdate.setTarget(centerCoordinate)
        self.mapView.animate(with: camera)
        self.mapView.animate(toZoom: zoom)
    }
}


extension MapsViewModel {
    func drawCircleOnMap(at point: Point) {
        let objsScan = ObjsScan(name: "", centerPoint: point, radius: MapMange.share.radiusScan)
        
        circleVM.checkExists(by: objsScan) { check, circle in
            if check {
                circleVM.moveCircle(from: objsScan, to: point)
            } else {
                circleVM.addCircle(from: objsScan) { obj in
                    obj?.map = mapView
                }
            }
        }
    }
    func moveCircleOnMap(form circle: CircleData) {
        circleVM.checkExists(by: circle) { check, newCircle in
            if check {
                circleVM.moveCircle(from: circle, to: circle.getCenterPoint())
            } else {
                circleVM.addCircle(from: circle) { obj in
                    obj?.map = mapView
                }
            }
        }
    }
    
    func updateBound() {
        if mapView.camera.target.latitude > MapMange.share.mapBound.xMax
            || mapView.camera.target.latitude < MapMange.share.mapBound.xMin
            || mapView.camera.target.longitude > MapMange.share.mapBound.yMax
            || mapView.camera.target.longitude < MapMange.share.mapBound.yMin
        {
            
            MapMange.share.isOverBound = true
        } else {
            MapMange.share.isOverBound = false
        }
    }
}


// MARK: for Polygon {
extension MapsViewModel {
    @MainActor func addPolygonOnMap(from polygonData: PolygonData) {
        let polygon = self.polygonVM.addPolygon(from: polygonData)
        polygon.map = self.mapView
    }
}

// MARK: - For Device
extension MapsViewModel {
    @MainActor
    func bindLocationManager(_ locationManager: LocationManager) {
            locationManager.$location
                .sink { [weak self] location in
                    guard let location = location else {
                        self?.polygonVM.clearAllPolygon()
                        self?.markerVM.clearMarkers(by: .USER) {}
                        print("location data is not available")
                        return }
                    
                    let point = locationManager.location
                    let latLong = Point(lat: location.coordinate.latitude
                                        , long: location.coordinate.longitude)
                    let objDevice = ObjDevice(name: "User", point: latLong)
                    self?.addMarker(from: objDevice)
                    
                    //arrowtriangle.up.fill
                    //self?.updateCameraPosition(location: location)
                }
                .store(in: &cancellables)
            
            locationManager.$userHeading
                .sink { [weak self] heading in
                    guard let heading = heading else { 
                        self?.userHeading = (false, 0.0)
                        print("Heading data is not available")
                        return }
                    
                    guard locationManager.isLocationEnabled else { 
                        
                        self?.userHeading = (false, 0.0)
                        return }
                    
                    guard heading.headingAccuracy >= 0 else {
                        self?.userHeading = (false, 0.0)
                        return }
                    
                    let trueHeading = heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
                    // Giảm tần suất cập nhật góc quay bằng cách sử dụng threshold
                    if let lastHeading = self?.lastHeading, abs(trueHeading - lastHeading) < 5 {
                        return
                    }
                    self?.lastHeading = trueHeading
                    
                    guard let location = locationManager.location?.coordinate else {
                        self?.userHeading = (false, 0.0)
                        return }
                    
                    self?.userHeading = (true, trueHeading)
                    MapMange.share.mapBearing = trueHeading
                    let conicalData = ConicalModel(name: "polygonScan", centerPoint: location, direction: trueHeading, angle: MapMange.share.mapScanAngle, radius: 200)
                    // MapMange.share.radiusScan
                    
                    self?.addPolygonOnMap(from: conicalData)
                    
                    if locationManager.deviceLocationStatus == .Direction {
                        self?.rotateMap(by: trueHeading)
                    }
                    
                }
                .store(in: &cancellables)
        }
    
    func rotateMap(by direction: CLLocationDirection) {
        // Đảm bảo rằng cập nhật chỉ xảy ra khi cần thiết
        let minimumRotationThreshold: CLLocationDirection = 5.0 // Điều chỉnh giá trị ngưỡng tùy theo nhu cầu

        DispatchQueue.main.async {
            // Giới hạn tần suất cập nhật để giảm tải
            guard abs(self.mapView.camera.bearing - direction) > minimumRotationThreshold else { return }
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.25) // Tinh chỉnh thời gian hoạt ảnh nếu cần
            self.updateArrowRotateMarkers(direction == 0 ? 0.0 : self.userHeading.1)
            self.mapView.animate(toBearing: direction)
            
            
            CATransaction.commit()
            
        }
    }
    
    func updateArrowRotateMarkers(_ angle: CLLocationDirection = 0.0) {
        markerVM.updateArrowRotateMarkers(with: angle, by: .ARROW)
        markerVM.updateArrowRotateMarkers(with: angle, by: .WINDDIRECTION)
    }
    
    func mapView(_ mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
            // Cập nhật góc quay của từng marker khi map thay đổi hướng
        //self.updateArrowRotateMarkers()
        }
}

extension CLLocationCoordinate2D {
    func coordinate(with bearing: Double, distance: Double) -> CLLocationCoordinate2D {
        let distRadians = distance / 6378137.0 // Earth's radius in meters
        let bearingRadians = bearing * .pi / 180

        let lat1 = self.latitude * .pi / 180
        let lon1 = self.longitude * .pi / 180

        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearingRadians))
        let lon2 = lon1 + atan2(sin(bearingRadians) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))

        return CLLocationCoordinate2D(latitude: lat2 * 180 / .pi, longitude: lon2 * 180 / .pi)
    }
}
