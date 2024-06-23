//
//  MarkerType.swift
//  SinTraffic
//
//  Created by pc on 16/01/2024.
//

import Foundation
import SwiftUI

enum MarkerIconType: String, Hashable {
    case BUSSTOP = "BUSSTOP"
    case BUS = "BUS"
    case CARPARK = "CARPARK"
    case TAXI = "TAXI"
    case BICYCLE_PARKING = "BICYCLE_PARKING"
    case CAMERA = "CAMERA"
    case ACCIDENT = "ACCIDENT"
    case Train = "Train"
    case INCIDENT = "INCIDENT"
    
    case WEATHER = "Weather"
    case HUMIDITY = "Humidity"
    case WINDDIRECTION = "WindDirection"
    
    case BusAndTrain = "BusAndTrain"
    
    case ARROW = "ARROW"
    case SCAN = "SCAN"
    case USER = "USER"
    case DEVICE = "DEVICE"
    case NodePolyline = "NodePolyline"
    case CENTERMAP = "CenterMap"
}

extension MarkerIconType {
    
    func getIcon(has active: Bool = false) -> AnyView {
        switch self {
        case .BUSSTOP:
            AnyView(IconBusView(hasActive: active))
        case .TAXI:
            AnyView(IconTaxiView(hasActive: active))
        case .CARPARK:
            AnyView(IconCarparkView(hasActive: active))
        case .BICYCLE_PARKING:
            AnyView(IconBicycleParkingView(hasActive: active))
        case .CAMERA:
            AnyView(IconCameraView(hasActive: active))
        case .INCIDENT:
            AnyView(IconIncidentView(hasActive: active))
        case .ARROW:
            AnyView(Image(systemName: "arrowtriangle.up.fill"))
        case .BUS:
            AnyView(EmptyView())
        case .ACCIDENT:
            AnyView(EmptyView())
        case .Train:
            AnyView(Image(systemName: "train.side.front.car"))
        case .SCAN:
            AnyView(IconScanView(hasActive: active))
        case .USER:
            AnyView(IconUserView(hasActive: active))
        case .NodePolyline:
            AnyView(IconNodePolylineView())
        case .DEVICE:
            AnyView(EmptyView())
        case .CENTERMAP:
            AnyView(EmptyView())
        case .WEATHER:
            AnyView(EmptyView())
        case .HUMIDITY:
            AnyView(EmptyView())
        case .WINDDIRECTION:
            AnyView(EmptyView())
        case .BusAndTrain:
            AnyView(EmptyView())
            
        }
    }
    
    
    @ViewBuilder
    func getInforMarkerView(mapStyle: MapStyle, model: Decodable) -> some View {
        
        //guard let model = model! as Decodable else { EmptyView() }
        switch self {
        case .BUSSTOP:
            BusStopMarkerInforView(mapStyle: mapStyle, model: model as! BusStopModel)
                .fixedSize(horizontal: true, vertical: true)
        case .BUS:
            BusMarkerInforView(mapStyle: mapStyle, model: model as! BusModel)
        case .CARPARK:
            carparkMarkerInforView(mapStyle: mapStyle, model: model as! CarParkModel)
        case .TAXI:
            TaxiInforMarkerView(mapStyle: mapStyle, model: model as! TaxisModel)
                .fixedSize(horizontal: false, vertical: true)
        case .BICYCLE_PARKING:
            BicycleParkingInforMarkerView(mapStyle: mapStyle, model: model as! BicycleParkingModel)
                .fixedSize(horizontal: true, vertical: true)
        case .CAMERA:
            CameraMarkerInforView(mapStyle: mapStyle, model: model as! CameraModel)
        case .ACCIDENT:
            BusStopMarkerInforView(mapStyle: mapStyle, model: model as! BusStopModel)
        case .Train:
            TrainStationMarkerInforView(mapStyle: mapStyle, model: model as! TrainStationModel)
                .fixedSize(horizontal: true, vertical: true)
        case .ARROW, .INCIDENT, .SCAN, .USER, .NodePolyline, .DEVICE, .CENTERMAP:
            EmptyView()
        case .WEATHER:
            WeatherMarkerInforView(model: model as! TwoHourWeatherForecastModel, mapStyle: mapStyle)
                .fixedSize(horizontal: false, vertical: true)
        case .HUMIDITY:
            EmptyView()
        case .WINDDIRECTION, .BusAndTrain:
            EmptyView()
            //WindDirectionMarkerInforView(model: model as! WindDirectionModel, mapStyle: mapStyle)
                //.fixedSize(horizontal: false, vertical: true)
        }
    }
}
